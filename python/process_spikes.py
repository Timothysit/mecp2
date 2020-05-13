import numpy as np
import xarray as xr
import pandas as pd
import numpy as np
import scipy.sparse as ssparse
from tqdm import tqdm
import sparse

import h5py

import os
import glob


def bin_spikes_sparse(spike_df, spike_time_column='spikeTime',
                      cluster_column='cellId',
                      sampling_rate=2000, output_type='dense'):
    min_time = np.min(spike_df[spike_time_column])
    max_time = np.max(spike_df[spike_time_column])
    num_bins = int(max_time - min_time) * sampling_rate
    num_neurons = len(np.unique(spike_df[cluster_column]))

    sparse_vector_list = list()
    for cell_id in tqdm(np.unique(spike_df[cluster_column])):
        cell_spike_df = spike_df.loc[
            spike_df[cluster_column] == cell_id]
        binned_vector, time_coords = np.histogram(cell_spike_df, num_bins,
                                                  range=(min_time, max_time))
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


def add_one(value):

    value = value + 1

    return value


def load_spyking_circus_results(spyking_circus_output_dir):
    """
    Loads spikes detected from spyking circus.
    Parameters
    ----------
    spyking_circus_output_dir

    Returns
    -------

    """

    result_file = glob.glob(os.path.join(spyking_circus_output_dir, '*.result-merged.hdf5'))[0]
    spike_sorting_result = h5py.File(result_file, 'r')

    cluster_file = glob.glob(os.path.join(spyking_circus_output_dir, '*clusters-merged.hdf5'))[0]
    cluster = h5py.File(cluster_file, 'r')
    template_to_electrode_map = cluster['electrodes'][()]

    # Make dataframe of the spike of each template
    template_spiketime_dict = dict()
    template_spiketime_dict['template'] = list()
    template_spiketime_dict['spiketime'] = list()
    template_spiketime_dict['electrode'] = list()

    fs = 25000
    for template_n, template_field in enumerate(spike_sorting_result['spiketimes']):
        template_spiketimes = spike_sorting_result['spiketimes'][template_field][()]
        template_spiketime_dict['template'].extend(np.repeat(template_n, len(template_spiketimes)))
        template_spiketime_dict['spiketime'].extend(template_spiketimes / fs)

        # Add electrode number
        electrode_num = template_to_electrode_map[template_n]
        template_spiketime_dict['electrode'].extend(np.repeat(electrode_num, len(template_spiketimes)))

    template_spiketime_df = pd.DataFrame.from_dict(template_spiketime_dict)

    # Count number of spike per electrode
    spyking_circus_spike_count = template_spiketime_df.groupby('electrode').count()['spiketime']
    spike_count_per_electrode = add_zero_spikecount(spyking_circus_spike_count)

    return template_spiketime_df, spike_count_per_electrode


def add_zero_spikecount(spyking_circus_spike_count, num_electrode=60):

    for electrode in np.arange(num_electrode):
        if electrode not in spyking_circus_spike_count.index:
            spyking_circus_spike_count.loc[electrode] = 0
            # zero_spike_electrode = pd.DataFrame([0])
            # zero_spike_electrode.name = electrode
            # spyking_circus_spike_count = spyking_circus_spike_count.append(zero_spike_electrode)

    return spyking_circus_spike_count.sort_index()





