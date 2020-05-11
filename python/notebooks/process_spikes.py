import numpy as np
import xarray as xr
import pandas as pd
import numpy as np
import scipy.sparse as ssparse
from tqdm import tqdm
import sparse


def bin_spikes_sparse(spike_df, spike_time_column='spikeTime',
                      original_sampling_rate=25000, down_sample_factor=2500,
                      t_start=0, t_end=None,
                      cluster_column='cellId', sampling_rate=2000, output_type='dense',
                      cluster_idx=None, cluster_idx_to_row=None):
    """
    Convert spike data in the form of spike times to a matrix
    Parameters
    -------------

    """

    min_time = np.min(spike_df[spike_time_column])
    max_time = np.max(spike_df[spike_time_column])
    if (t_start is None) and (t_end is None):
        num_bins = int(max_time - min_time) * sampling_rate
    else:
        if t_start is None:
            t_start = min_time
        if t_end is None:
            t_end = max_time
        num_bins = int(original_sampling_rate / down_sample_factor * (t_end - t_start))

    if cluster_idx is None:
        cluster_idx = np.sort(np.unique(spike_df[cluster_column]))

    sparse_vector_list = list()
    for cell_id in tqdm(cluster_idx):
        cell_spike_df = spike_df.loc[
            spike_df[cluster_column] == cell_id]

        # NOTE: careful that histogram is performed on a single pandas series, otherwise
        # all other values in multiple columns will be used. (Resolved bug)
        binned_vector, time_coords = np.histogram(cell_spike_df[spike_time_column], num_bins,
                                                  range=(t_start, t_end))
        if output_type == 'sparse':
            sparse_vector = sparse.COO.from_numpy(binned_vector)
        elif output_type == 'ssparse':
            sparse_vector = ssparse.coo_matrix(binned_vector)
        elif output_type == 'dense':
            sparse_vector = binned_vector

        sparse_vector_list.append(sparse_vector)

    if output_type == 'sparse':
        sparse_matrix = sparse.stack(sparse_vector_list)
    elif output_type == 'ssparse':
        sparse_matrix = ssparse.vstack(sparse_vector_list)
    elif output_type == 'dense':
        sparse_matrix = np.vstack(sparse_vector_list)

    return sparse_matrix, time_coords


def spike_matrix_to_df(spike_matrix, unit_id_list, spike_time_column='spikeTime',
                       cluster_column='electrode', fs=25000):
    """
    Convert spike matrix to pandas dataframe with the spike times.
    Parameters
    ----------
    spike_matrix (numpy ndarray)
        2D numpy ndarray with shape (cluster, time)
    unit_id_list (list)
        list of values associated with each cell or cluster or recording channel
    fs (int)
        sampling rate (Hz)

    """
    spike_dict = dict()
    spike_dict[spike_time_column] = list()
    spike_dict[cluster_column] = list()

    for n_unit, unit_id in enumerate(unit_id_list):
        unit_spike_time = np.where(spike_matrix[n_unit, :])[0] / fs
        spike_dict[spike_time_column].extend(unit_spike_time)
        spike_dict[cluster_column].extend(np.repeat(unit_id, len(unit_spike_time)))

    spike_df = pd.DataFrame.from_dict(spike_dict)

    return spike_df