import argparse
import numpy as np
import os
from pymoab import core, tag, types


def parse_arguments():
    """
    Parse the argument list and return a mesh file location.

    Input:
    ______
       none

    Returns:
    ________
       args: Namespace
           User supplied mesh file location.
    """

    parser = argparse.ArgumentParser(description="Expand vector tags to scalar tags.")

    parser.add_argument("meshfile",
                        type=str,
                        help="Provide a path to the mesh file."
                        )

    args = parser.parse_args()

    return args


def get_tag_lists(mb, element):
    """
    Create separate lists of each scalar and vector tag in the mesh file by
    identifying each tag on a specific mesh element and determining the type.

    Input:
    ______
       mb: Core
           A PyMOAB core instance with a loaded data file.
       element: int
           The type of MOAB element from which to extract the tag list,
           represented by an integer.

    Returns:
    ________
       element_list: List of Integers
           A list of all specific elements in the mesh, in which the type is
           represented by an integer.
       scalar_tags: List of PyMOAB Tags
           A list of all scalar tags in the mesh.
       vector_tags: List of PyMOAB Tags
           A list of all vector tags in the mesh.

    Raises:
    _______
       LookupError: If no element of the user specified type is found.
    """

    # Retrieve an arbitrary MBHEX element in the mesh and extract the tag list.
    root = mb.get_root_set()
    element_list = mb.get_entities_by_type(root, element)

    # Warn the user if there are none of the specified mesh elements.
    if len(element_list) == 0:
        raise LookupError()

    tag_list = mb.tag_get_tags_on_entity(element_list[0])

    # Check the type of each tag and append to the appropriate list.
    scalar_tags = []
    vector_tags = []
    for tag in tag_list:
        tag_length = mb.tag_get_length(tag)
        if tag_length > 1:
            vector_tags.append(tag)
        else:
            scalar_tags.append(tag)

    return element_list, scalar_tags, vector_tags


def create_database(mesh_file, mb, hexes, scal_tags, vec_tag):
    """
    Expand the vector tag on each element in the given mesh data file. Write a
    file to disk for each index with the corresponding scalar tag value.

    Input:
    ______
       mesh_file: str
           User supplied mesh file location.
       mb_ref: Core
           A PyMOAB core instance with a loaded data file for reference.
       mb_exp: Core
           A PyMOAB core instance with a loaded data file for expanding
           vector tags.
       hexes: List of Integers
           A list of all hex elements in the mesh.
       scal_tags: List of PyMOAB Tags
           A list of all scalar tags in the mesh.
       vec_tag: PyMOAB Tag
           The vector tag to be expanded.
       dir_name: str
           The name of the directory in which to create and populate each
           vector tag directory.

    Returns:
    ________
       none
    """

    # Get the length and tag name of the vector tag.
    length = vec_tag.get_length()
    name = vec_tag.get_name()

    # Create a directory to store the vector tag expansion files.
    vec_dir_name = name + "_database"
    os.mkdir(dir_name + "/" + vec_dir_name)

    """
    For the vector tag on each element, retrieve the scalar value at a specific
    index and create a scalar tag. For each index, write the scalar tag value
    to disk in a vtk file in the specified database.
    """

    index = 0
    while index < length:
        scalar_data = []
        data = mb.tag_get_data(vec_tag, hexes)
        scalar_data = np.copy(data[:,index])
        data_type = vec_tag.get_data_type()
        scalar_tag = mb.tag_get_handle(name, 1, data_type, types.MB_TAG_SPARSE,
                                       create_if_missing = True)
        mb.tag_set_data(scalar_tag, hexes, scalar_data)

        # Write the file with the new scalar tag.
        file_location = os.getcwd() + "/" + dir_name + "/" + vec_dir_name + "/" + name + str(index) + ".vtk"
        scal_tags.append(scalar_tag)
        mb.write_file(file_location, output_tags = scal_tags)

        # Remove the new scalar tag and prepare for the next.
        scal_tags = scal_tags[:-1]
        index += 1

    print(str(index) + " files have been written to disk.")


def expand_vector_tags(mesh_file):
    """
    Load the mesh file and extract the lists of scalar and vector tags, then
    expand each vector tag.

    Input:
    ______
       mesh_file: str
           User supplied mesh file location.

    Returns:
    ________
       none

    Raises:
    _______
       LookupError: If the file does not contain any vector tags.
    """

    # Load the mesh file.
    mb = core.Core()
    mb.load_file(mesh_file)

    # Retrieve the lists of scalar and vector tags on the mesh.
    try:
        hexes, scal_tags, vec_tags = get_tag_lists(mb, types.MBHEX)
    except LookupError:
        print("WARNING: No hex elements were found in the mesh.")
        exit()

    # Warn the user if the mesh file does not contain at least one vector tag.
    if len(vec_tags) < 1:
        raise LookupError("WARNING: This mesh file did not contain any vector tags.")

    # Create a directory for the vector tag expansion files.
    input_list = mesh_file.split("/")
    file_name = '.'.join(input_list[-1].split(".")[:-1])
    dir_name = file_name + "_database"

    # Ensure an existing dictionary is not written over.
    dict_number = 1
    while os.path.isdir(dir_name):
        dir_name = file_name + "_database" + str(dict_number)
        dict_number += 1
    os.mkdir(dir_name)

    # Expand each vector tag present in the mesh.
    for tag in vec_tags:
        create_database(mesh_file, mb, hexes, scal_tags, tag)


def main():

    # Parse arguments.
    args = parse_arguments()

    # Expand the vector tags from the mesh file.
    try:
        expand_vector_tags(args.meshfile)
    except LookupError as e:
        print(str(e))
        exit()


if __name__ == "__main__":
    main()
