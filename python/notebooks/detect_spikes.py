import numpy as np 
import scipy.signal as ssignal

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
