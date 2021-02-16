import glob
import os
import argparse
import pdb
import numpy as np
import PyPDF2
import re
import natsort

parser = argparse.ArgumentParser(description='Merge PDFs')


parser.add_argument('--input_folder',
                    metavar='input_folder',
                    type=str, default=None,
                    help='Input folder to merge PDF')
parser.add_argument('--output_folder',
                    metavar='output_folder',
                    type=str, default=None,
                    help='Output folder to save the result of merging PDFs')

def main():
    args = parser.parse_args()
    input_folder = args.input_folder
    output_folder = args.output_folder
    merge_file_ext = '.pdf'
    split_symbol = None  # what character is use to split information in filenames
                         # None means using white space

    if output_folder is None:
        print('Output folder not specified, saving to the sub-folder within the input folder')
        output_folder = os.path.join(input_folder, 'merged')

    if not os.path.exists(output_folder):
        os.mkdirs(output_folder)

    print('Merging files found in %s' % input_folder)

    # Find unique files
    all_files = glob.glob(os.path.join(input_folder, '*%s' % merge_file_ext))
    all_file_names = [os.path.basename(x) for x in all_files]
    all_file_names = [x.split('.')[0] for x in all_file_names]  # remove extension
    if split_symbol is not None:
        all_file_name_without_last_num = [split_symbol.join(x.split(split_symbol)[:-1]) for x in all_file_names]
    else:
        all_file_name_without_last_num = [' '.join(x.split()[:-1]) for x in all_file_names]

    unique_file_names = np.unique(all_file_name_without_last_num)

    print('Number of files found: %.f' % len(all_files))
    print('Number of unique datasets found: %.f' % len(unique_file_names))

    for unique_fname in unique_file_names:

        mergedObject = PyPDF2.PdfFileMerger()
        matching_files = glob.glob(os.path.join(input_folder, '*%s [0-9]*%s' % (unique_fname, merge_file_ext)))
        # note [0-9] allow for any number of digits, this is mainly needed
        # so pdfs with 'TTX' don't get mixed with those without.

        # Sorting filenames
        # See: https://stackoverflow.com/questions/33159106/sort-filenames-in-directory-in-ascending-order
        # matching_files = matching_files.sort(key=lambda f: int(re.sub('\D', '', f)))
        matching_files = natsort.natsorted(matching_files, reverse=False)


        for matching_fname in matching_files:
            mergedObject.append(PyPDF2.PdfFileReader(matching_fname, 'rb'))

        # Write all the files into a file which is named as shown below
        merged_filename = 'merged_%s%s' % (unique_fname, merge_file_ext)
        mergedObject.write(os.path.join(output_folder, merged_filename))

    print('Merging complete')


if __name__ == "__main__":
    main()
