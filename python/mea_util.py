import xarray as xr
import h5py
import numpy as np

import scipy.io as spio

def loadmat(filename, struct_as_record=False):
    """
    A better loadmat function than the default scipy one
    This function should be called instead of direct spio.loadmat
    as it cures the problem of not properly recovering python dictionaries
    from mat files. It calls the function check keys to cure all entries
    which are still mat-objects
    Parameters
    -----------
    struct_as_record : if True, you access fields using data['field']
    if False, you access field using dot notation: data.field

    """

    def _check_keys(d):
        '''
        checks if entries in dictionary are mat-objects. If yes
        todict is called to change them to nested dictionaries
        '''
        for key in d:
            if isinstance(d[key], spio.matlab.mio5_params.mat_struct):
                d[key] = _todict(d[key])
        return d

    def _todict(matobj):
        '''
        A recursive function which constructs from matobjects nested dictionaries
        '''
        d = {}
        for strg in matobj._fieldnames:
            elem = matobj.__dict__[strg]
            if isinstance(elem, spio.matlab.mio5_params.mat_struct):
                d[strg] = _todict(elem)
            elif isinstance(elem, np.ndarray):
                # TS: Make sure numpy array is at least 1 dimensional
                # Otherwise the loop in _tolist() will complain about 0-d arrays.
                elem = np.atleast_1d(elem)
                d[strg] = _tolist(elem)
            else:
                d[strg] = elem
        return d

    def _tolist(ndarray):
        '''
        A recursive function which constructs lists from cellarrays
        (which are loaded as numpy ndarrays), recursing into the elements
        if they contain matobjects.
        '''
        elem_list = []
        for sub_elem in ndarray:
            if isinstance(sub_elem, spio.matlab.mio5_params.mat_struct):
                elem_list.append(_todict(sub_elem))
            elif isinstance(sub_elem, np.ndarray):
                elem_list.append(_tolist(sub_elem))
            else:
                elem_list.append(sub_elem)
        return elem_list

    data = spio.loadmat(filename, struct_as_record=struct_as_record, squeeze_me=True)
    return _check_keys(data)



def hdf_loadmat(mat_filepath):
    f = h5py.File(mat_filepath)
    data_dict = {}
    for k, v in f.items():
        data_dict[k] = np.array(v)

    return data_dict


def mea_mat_to_numpy(mat_filepath, verbose=True):
    # load matlab file
    f = h5py.File(mat_filepath)
    data_dict = {}
    for k, v in f.items():
        data_dict[k] = np.array(v)

    # Re-order the channels to match that of the probe file
    channel_sorted_idx = np.argsort(data_dict['channels'][0])
    sorted_data_matrix = data_dict['dat'][channel_sorted_idx, :]

    # modify the name of the file to add the .npy extension
    original_filename = mat_filepath.split('.')[0]

    np.save(original_filename + '.npy', sorted_data_matrix)

    print('File succesfully saved to %s' % (original_filename + '.npy'))


def mea_mat_to_xarray(mea_data_dict, file_name=None):
    """
    Convert dictionary obtained from matlab file to xarray dataset.

    Parameters
    ----------
    mea_data_dict
    file_name

    Returns
    -------

    """
    fs = mea_data_dict['fs'][0][0]
    num_samples = np.shape(mea_data_dict['dat'])[1]
    time_in_sec = np.arange(num_samples) / fs
    mea_ds = xr.Dataset({'raw': (['Channel', 'Time'], mea_data_dict['dat'])},
                        coords={'Channel': ('Channel', mea_data_dict['channels'][0]),
                                'Time': ('Time', time_in_sec)})

    mea_ds.attrs['ADCz'] = mea_data_dict['ADCz'][0][0]
    mea_ds.attrs['fs'] = fs
    if file_name is not None:
        mea_ds.attrs['name'] = file_name

    return mea_ds

def make_grid_matrix(data_vec, num_x_channel=8, num_y_channel=8, grounded_electrode=[15]):
    """
    Reorganise data into the a matrix that corresponds to the physical location of the electrodes.
    This is ported from:
    https://github.com/Timothysit/mecp2/blob/master/Matlab_Analysis/heatMap/makeHeatMap.m
    Parameters
    ----------
    data_vec
    num_x_channel
    num_y_channel
    grounded_electrode

    Returns
    -------

    """
    grid_matrix = np.zeros((num_x_channel, num_y_channel))

    # remove the four corners
    grid_matrix[0, 0] = np.nan
    grid_matrix[0, 7] = np.nan
    grid_matrix[7, 0] = np.nan
    grid_matrix[7, 7] = np.nan

    num_channel = len(data_vec)

    if num_channel == 60:
        grid_matrix.T.flat[1:7] = data_vec[0:6]
        grid_matrix.T.flat[8:56] = data_vec[6:54]
        grid_matrix.T.flat[57:63] = data_vec[54:60]

    return grid_matrix


