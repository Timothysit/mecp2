import numpy as np
import scipy.signal as ssignal
import pywt

def detect_spikes(raw_data, method='manuel', fs=25000):
    """
    Detect spikes from raw electrode data.
    Parameters
    ----------
    raw_data
    method (str)
        method for spike detection
    fs : (int)
        sampling rate

    Returns
    -------

    """

    if method == 'manuel':
        low_pass = 600
        high_pass = 8000
        filter_order = 3

        wn = np.array([low_pass, high_pass]) / (fs / 2)

        b, a = ssignal.butter(filter_order, Wn=wn, btype='bandpass')

    elif method == 'wavelet':
        print('Still need to port wavelet method to python')

    return spike_matrix


def filter_raw_traces(raw_data, low_pass=600, high_pass=8000, filter_order=3, fs=25000):
    """

    Parameters
    ----------
    raw_data  : (numpy ndaarray)
        numpy ndarray with shape (numChennl, numSamples)
    low_pass : (float)
        lower cutoff frequency (Hz)
    high_pass : (float)
        higher cutoff frequency (Hz)
    filter_order : (int)
        filter order
    fs : (int)
        sampling rate

    Returns
    -------

    """


    wn = np.array([low_pass, high_pass]) / (fs / 2)
    b, a = ssignal.butter(filter_order, Wn=wn, btype='bandpass')

    filtered_data = list()

    for channel_trace in raw_data:

        filtered_channel = ssignal.filtfilt(b, a, channel_trace)
        filtered_data.append(filtered_channel)

    filtered_data = np.stack(filtered_data)

    return filtered_data



def load_spyking_circus_data(verbose=True):


    return spkying_circus_data

def template_matrix_to_electrode_matrix():




    return electrode_spike_matrix



def determine_scales(wname, Wid, SFr, Ns):
    """

    Parameters
    ----------
    wname
    Wid
    SFr : (int)
        sampling rate (kHz)
    Ns  : (int)
        number of scales

    Returns
    -------

    """

    # Signal sampled at 1 kHz
    signal = np.zeros(shape=(1000))

    dt = 1 / SFr   # millisecond

    # Create Dirac function
    signal[499] = 1

    Width = np.linspace(Wid[0], Wid[1], Ns)

    # Infinitesimally small number
    Eps = 10 ** (-15)

    ScaleMax = 3
    ScaleMax = ScaleMax * SFr

    # TODO: db2 can also be incorporated into the code below, reduce repeating code

    if wname == 'haar':
        for i in np.arange(Ns):
            Scale[i] = Width[i] / dt - 1
    elif wname == 'db2':
        Scales = np.arange(1, ScaleMax+1)
        for i in len(Scales):
            # indicators of positive coefficients
            IndPos = c[i, :] > 0
            # indicators of derivative
            IndDer = np.diff(IndPos)
            # indices of negative slope zero crossings
            IndZeroCross = np.where(IndDer == -1)
            IndMax = IndZerCross > 499
            Ind[1] = np.min(IndZeroCross[IndMax]) + 1
            IndMin = IndZeroCross < 499
            Ind[0] = np.max(IndZeroCross[IndMin])
            WidthTable[i] = np.diff(Ind) * dt
        WidthTable = WidthTable + [np.arange(len(Scales))] * Eps
        # Look-up table
        Scale = np.round(np.interp(WidthTable, Scales, Width))  # linear interpolation
    elif wname in ['sym2', 'bior1.3', 'bior1.5']:
        Scales = np.arange(1, ScaleMax+1)
        c = pywt.cwt(data=Signal, scales=Scales, wavelet=wname)
        for i in np.arange(len(Scales)):
            # indicators of positive coefficients
            IndPos = c[i, :] > 0
            # indicators of derivative
            IndDer = np.diff(IndPos)
            if wname == 'sym2':
                # indices of positive slope zero crossings
                IndZeroCross = np.where(IndDer == 1)
            else:
                # indices of negative slope zero crossings
                IndZeroCross = np.where(IndDer == -1)
            IndMax = IndZeroCross > 499
            Ind[1] = np.min(IndZeroCross[IndMax]) + 1
            IndMin = IndZeroCross < 499
            Ind[0] = np.max(IndZeroCross[IndMin])
            WidthTable[i] = np.diff(Ind) * dt
        WidthTable = WidthTable + np.arange(len(Scales)) * Eps
        # Loop-up table
        Scale = np.round(np.interp(WidthTable, Scales, Width))  # linear interpolation
    else:
        print('Unknown wavelet family')
        Scale = None

    return Scale


def parse(Index, SFr, Wid):
    """
    This is a special function, it takes the vector index which has the structure
    [0 0 0 1 1 1 0 ... 0 1 0 ... 0 ]
    This vector was obtained by coincidence detection of certain events (lower and upper threshold
    crossing for threshold detection, and the appearance of coefficients at different scales for wavelet detection)
    The real challenge here is to merge multiple 1's that belong to the same spike into one event and to locate
    that event

    Parameters
    ----------
    Index
    SFr
    Wid

    Returns
    -------

    """

    Refract = 1.5 * Wid[1]   # refractory period in (ms)
                             # can't resolve spikes that are close than refract
    Refract = np.round(Refract * SFr)

    Merge = np.mean(Wid)

    Merge = np.round(Merge * SFr)

    # Discard spikes located at the first and last samples
    Index[0] = 0
    Index[-1] = 0

    ind_ones = np.where(Index == 1)  # find where the ones are

    if len(ind_ones) == 0:
        TE = []
    else:
        temp = np.diff(Index)   # there will be 1 followed by -1 for each spike
        N_sp = np.sum(temp == 1)  # nominal number of spikes

        lead_t = np.where(temp == 1)  # index of the beginning of a spike
        lag_t = np.where(temp == -1)  # index of the end of the spike

        for i in np.arange(N_sp):
            # find the middle point of the spike (I think)
            tE[i] = np.ceil(np.mean([lead_t[i], lag_t[i]]))

        i = 1
        while 0 < 1:
            if i > (len(tE) - 1):
                break
            else:
                Diff = tE[i + 1] - tE[i]
                if (Diff < Refract) & (Diff > Merge):
                    tE[i + 1] = []   # dicard spike too close to its predecessor
                elif Diff <= Merge:
                    tE[i] = np.ceil(np.mean([tE[i], tE[i+1]]))  # merge spikes
                    tE[i + 1] = []  # dicard
                else:
                    i = i + 1
        TE = te

    fcn = Te

    return fcn


def detect_spikes_wavelet(signal, sFr=25, Wid=[0.5, 1.0], Ns=2, option='c', L=0, wname='bior1.5'):
    """
    Python port of the wavelet spike detection method by Zoran Nenadic
    Reference: Z. Nenadic and J.W. Burdick, Spike detection using the
    continuous wavelet transform, IEEE T. Bio-med. Eng., vol. 52,
    pp. 74-87, 2005. This is based on the modified version on February 2008 by
    the same author.

    Ported to Python by Tim Sit UCL 2020

    Parameters
    ----------
    signal : (numpy ndarray)
        extracellular potential data to be analyse
        should have shape 1 x Nt
    sFr : (int)
        sampling frequency in kHz
    Wid : (list or numpy ndarray)
        1 x 2 vector of expected minimum and maximum width msec of transient to be
        detected. Wid = [Wmin Wmax]. For more practical purposes Wid = [0.5, 1.0]
    Ns : (int)
        number of scales to use in detection.
        Ns >= 2
    option : (str)
        action to take when no coefficients surviv hard thresholding
        'c' : conservatice and returns no spikes if P(S) is found to be 0
        'l' : assume P(S) as a vague prior
    L : (float)
        factor that multiplies [cost of comission]  / [cost of omission]
        for more practical purposes -0.2 <= L <= 0.2.
        Larger L --> omissions more likely
        Smaller L --> false positives more likely
        For unsupervised detection, the suggested value of L is close to 0.
    wname : (str)
        wavelet family to use to find spikes with matching waveforms
        'bior1.5' : biorthogonal
        'bior1.3' : biorthogonal
        'db2'     : Daubechies
        'sym2'    : symmlet
        'haar'    : Haar function

    Returns
    -------
    TE : (numpy ndarray)
        array of shape (1, numSamples)
        vector of spikes (1 = spike, 0 = no spike)

    """

    wfam = ['bior1.5', 'bior1.3', 'sym2', 'db2', 'haar']

    # Make sure to specified wavleet is in the supported wavelet families
    assert wname in wfam

    # Mean subtraction on the signal so that it has zero-mean
    signal = signal - np.mean(signal)

    Nt = len(signal)  # number of time poinnts

    # define relevant scales for detection
    W = determine_scales(wname, Wid, SFr=sFr, Ns=Ns)

    # initialize the matrix of thresholded coefficients
    ct = np.zeros(shape=(Ns, Nt))

    # Get all coefficients
    c = pywt.cwt(signal, W, wname)  # pywavelet syntax is closer to matlab than scipy

    # define detection parameter
    Lmax = 36.7368  # log(Lcom / Lom), where the ratio is the maximum allowed
                    # by the current machine precision

    L = L * Lmax

    # intiialise the vector of spike indicator, 0: no spike, 1: spike
    Io = np.zeros(shape=(1, Nt))

    # Loop over scales
    for i in np.arange(Ns):

        # take only coefficients that are independent (W(i) apart) for median
        # standard deviation

        Sigmaj = np.median(abs(c[i, 0:np.round(W[i]):] - np.mean(c[i, :]))) / 0.6745
        Thj = Sigmaj * np.sqrt(2 * np.log(Nt))  # hard threshold
        index = np.where(np.abs(c[i, :]) > Thj)[0]
        if (len(index) == 0) & (option == 'c'):
            ct = [0]  # do nothing, there are no spikes
        elif(len(index) == 0) & (option == 'l'):
            Mj = Thj
            # Assume there is at least one spike
            PS = 1 / Nt
            PN = 1 - PS
            DTh = Mj / 2 + Sigmaj ** 2 / Mj * (L + np.log(PN / PS))  # decision threshold
            DTh = np.abs(Dth) * (DTh >= 0)   # Make Dth >= 0
            ind = np.where(np.abs(c[i, :]) > Dth)
            if len(ind) == 0:
                ct = [0]  # do nothin
            else:
                ct[i, ind] = c[i, ind]
        else:
            Mj = np.mean(np.abs(c[i, index]))  # mean of the signal coefficients
            PS = len(index) / Nt  # prior of spikes
            PN = 1 - PS  # prior of noise
            DTh = Mj / 2 + Sigmaj ** 2 / Mj * (L + np.log(PN/PS))  # decision thrsehold
            Dth = np.abs(DTh) * (DTh >= 0)  # Make Dth >= 0
            ind = np.where(np.abs(c[i, :]) > Dth)
            ct[i, ind] = c[i, ind]


        # Find which coefficients are non-zero
        Index = ct[i, :] != 0

        # Make a union with coefficients from previous scales
        Index = np.logical_or(Io, Index)
        Io = Index

    TE = parse(Index, SFr, Wid)
    # TODO: (optional) implement plotting
    # TODO: (optional) implement verbose

    NaNInd = np.isnan(Scale)

    if np.sum(NaNInd) > 0:
        print('Warning: your choise of Wid is not valid given the sampling rate and wavelet family')

        if NaNInd[0] == 0:
            print('Most likely because Wid[0] is too small')
        else:
            print('Most likely because Wid[1] is too large')
            print('Change the value on line ScaleMax = 2 to something larger')


    return TE
