import numpy as np
import xarray as xr
import pandas as pd
import numpy as np
import scipy.sparse as ssparse
from tqdm import tqdm
import sparse


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

