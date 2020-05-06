import matplotlib.pyplot as plt
import mea_util
import numpy as np

"""
def add_grid_text(fig, ax, num_electrode=60, color='white', size=10):


    electrode_numbers = [12, 13, 14, 15, 16, 17,
                         21, 22, 23, 24, 25, 26, 27, 28,
                         31, 32, 33, 34, 35, 36, 37, 38,
                         41, 42, 43, 44, 45, 46, 47, 48,
                         51, 52, 53, 54, 55, 56, 57, 58,
                         61, 62, 63, 64, 65, 66, 67, 68,
                         71, 72, 73, 74, 75, 76, 77, 78]

    # Loop over data dimensions and create text annotations.
    electrode_idx = 0
    for i in range(8):
        for j in range(8):
            text = ax.text(j, i, '{:.0f}'.format(X[i, j]),
                           ha="center", va="center", color=color)


    return fig, ax
"""


def plot_grid_layout(fig=None, ax=None, grid_matrix=None, grid_channel_num_matrix=None):
    if (fig is None) and (ax is None):
        fig, ax = plt.subplots()
        fig.set_size_inches(4, 4)

    if grid_matrix is not None:
        ax.imshow(grid_matrix)
    else:
        ax.imshow(np.tile(np.nan, np.shape(grid_channel_num_matrix)))

    if grid_channel_num_matrix is not None:

        for i in range(np.shape(grid_channel_num_matrix)[0]):
            for j in range(np.shape(grid_channel_num_matrix)[1]):
                text = ax.text(j, i, grid_channel_num_matrix[i, j], ha='center', va='center',
                               color='black')

    # Annotate channel number

    return fig, ax