import argparse
import os
#import visit as Vi
#from DataLoading import py_mb_convert
#from GraveIdentifyAndRemove import remove_graveyard
#from pymoab import core, tag, types


def parse_arguments():
    """
    Parse the argument list and return the location of a new geometry file and
    the location of a new data file.

    Input:
    ______
       none

    Returns:
    ________
       args: Namespace
           User supplied geometry file location and data file location.
    """

    parser = argparse.ArgumentParser(description="Replace data in session file.")

    parser.add_argument("-g", "--geofile",
                        type=str,
                        help="Provide a path to the geometry file."
                        )
    parser.add_argument("-d", "--datafile",
                        type=str,
                        help="Provide a path to the data file."
                        )

    args = parser.parse_args()

    return args


def replace_session_data(geometry_file = None, data_file = None):
    """
    Convert geometry file to stl, convert data file to vtk, replace the data
    in the session file, and open VisIt with the updated session file.

    Input:
    ______
       geometry_file: h5m file
           User supplied file containing geometry of interest.
       data_file: h5m or vtk file
           User supplied file containing data of interest.

    Returns:
    ________
       none
    """

    if geometry_file is None and data_file is None:
        print("WARNING: No new geometry or data file provided.")
        exit()

    if geometry_file is not None:
        # Remove the graveyard from the geometry file.
        try:
            geometry_file = remove_graveyard(geometry_file)
        except LookupError, e:
            print(str(e))
            pass
        # Convert the geometry file to the proper format.
        geometry_file = py_mb_convert(geometry_file, ".stl")

    if data_file is not None:
        # Convert the data file to the proper format.
        data_file = py_mb_convert(data_file, ".vtk")

    # Replace the database(s) in VisIt and recreate the sessionfile.
    # Open VisIt with the new data loaded in the old plots.


def main():

  # Parse arguments.
  args = parse_arguments()

  # Replace the data in the session file with what the user supplied.
  replace_session_data(args.geofile, args.datafile)


if __name__ == "__main__":
  main()
