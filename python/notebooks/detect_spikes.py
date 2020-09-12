import numpy as np 
import scipy.signal as ssignal
import pdb  # debugging


def detect_spikes(spike_data, method='manuel', fs=25000, multiplier=5):
    """
    Detection of spikes from raw MEA data.
    
    Parameters 
    -----------
    method : (str)
        method used to perform spike detection
    fs : (int)
        sampling rate
    """
    
    if method == 'manuel':
        low_pass = 600
        high_pass = 8000 
        filter_order = 3
        
        wn = np.array([low_pass, high_pass]) / (fs / 2)
        
        b, a = ssignal.butter(filter_order, Wn=wn, btype='bandpass')
        
        filtered_data = ssignal.filtfilt(b, a, spike_data)
        
        # finding threshold and spikes
        m = np.mean(filtered_data); 
        s = np.std(filtered_data); 
        threshold = m - multiplier * s; 
        neg_threshold = m - 8 * s; # maximum threshold, a simple artefact removal method 
        spike_train = (filtered_data < threshold).astype(int)
        
        
        # Impose refractory period 
        ref_period = 2.0 * 10 ** -3 * fs
        
        # for spike_idx in np.arange(len(spike_train)):
        #    if spike_train[]
        
        
    elif method == 'cwt':
        
        # Filter
        lowpass = 600; 
        highpass = 8000; 
        
        wn = np.array([lowpass, highpass]) / (fs / 2); 
        
        filterOrder = 3;
        [b, a] =ssignal.butter(filterOrder, wn, btype='bandpass'); 
        filtered_data = ssignal.filtfilt(b, a, spike_data); 
    
    
    else:
        print('No valid spike detection method specified, returning None')
        spike_train = None
        

    return spike_train


def down_sample_spike_matrix(spike_matrix, down_sample_factor=2500):

    original_num_samp = np.shape(spike_matrix)[1]
    new_num_samp = original_num_samp / down_sample_factor 
    reshaped_spike_matrix = np.reshape(spike_matrix, (int(num_channels), int(new_num_samp), -1))
    down_sampled_matrix = np.sum(reshaped_spike_matrix, axis=-1)
    
    return down_sampled_matrix


def find_intersect_spikes(spike_struct, fs=25000, round_decimal_places=3):
    """
    Obtains the unique spike times from a structure containing the detected
    spike using multiple methods, and outputs a matrix where each row
    corresponds to a single unique spike time, and where each column
    represents a spike detection method. An entry of 1 in the matrix
    means that the spike detection method identified a spike at that time
    and 0 otherwise.
    Parameters
    -------------
    spike_struct : (dict)
    fs : (int)
        sampling rate (Hz)
    round_decimal_places : (int)
        number of decimal places in seconds to round
        eg. 3 will mean rounding the spikes to the nearest 1 ms
    """



    wavelet_method_used = spike_struct.keys()
    all_spike_times = list()

    for wavlet_method, spike_idx in spike_struct.items():
        spike_times = np.array(spike_idx) / fs
        all_spike_times.append(spike_times)

    # pdb.set_trace()
    all_spike_times = np.concatenate(all_spike_times)

    if round_decimal_places > 0:
        all_spike_times = np.round(all_spike_times, round_decimal_places)

    unique_spike_times = np.unique(all_spike_times)

    intersection_matrix = np.zeros(shape=(len(unique_spike_times), len(wavelet_method_used)))

    for wavelet_n, (wavelet_method, spike_idx) in enumerate(spike_struct.items()):
        spike_times = np.array(spike_idx) / fs
        if round_decimal_places > 0:
            spike_times = np.round(spike_times, round_decimal_places)

            for unique_spike_t_index, unique_spike_t in enumerate(unique_spike_times):

                if unique_spike_t in spike_times:
                    intersection_matrix[unique_spike_t_index, wavelet_n] = 1


    return intersection_matrix, unique_spike_times


def align_spikes():




    return aligned_spike_matrix