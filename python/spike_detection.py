import numpy as np
import scipy.signal as ssignal


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


def load_spyking_circus_data(verbose=True):


    return spkying_circus_data

def template_matrix_to_electrode_matrix():




    return electrode_spike_matrix


def detect_spikes_wavelet(signal, sFr, Wid, Ns, option, L, wname):
    """
    Python port of the wavelet spike detection method by Zoran Nenadic
    Reference: Z. Nenadic and J.W. Burdick, Spike detection using the
    continuous wavelet transform, IEEE T. Bio-med. Eng., vol. 52,
    pp. 74-87, 2005.

    Ported to Python by Tim Sit UCL 2020

    Parameters
    ----------
    signal
    sFr
    Wid
    Ns
    option
    L
    wname

    Returns
    -------

    """

    wfam = ['bior1.5', 'bior1.3', 'sym2', 'db2', 'haar']

    Nt = len(Signal)  # number of time poinnts

    # define relevant scales for detection
    W = determine_scales(wname, Wid, Sfr, Ns)

    # initialize the matrix of thresholded coefficients
    ct = np.zeros(shape=(Ns, Nt))

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

        Sigmaj = np.median(abs(c[i, 0:np.round(W[i]):] - np.mean(c[i, :])))  / 0.6745



    def determine_scales(wname, Wid, SFr, Ns):
        """

        Parameters
        ----------
        wname
        Wid
        SFr
        Ns

        Returns
        -------

        """

        # Signal smapled at 1 kHz
        Signal = np.zeros(shape=(1, 1000))

        dt = 1 / SFr   # millisecond

        # Create Dirac function
        Signal[409] = 1

        Width = np.linspace(Wid[0], Wid[1], Ns)

        # Infinitesimally small number
        Eps = 10 ** (-15)

        ScaleMax = 3
        ScaleMax = ScaleMax * SFr

        if wname == 'haar':
            for i in np.arange(Ns):
                Scale[i] = Width[i] / dt - 1
        elif wname == 'db2':
            Scale = np.arange(1, ScaleMax+1)


        return Scale
