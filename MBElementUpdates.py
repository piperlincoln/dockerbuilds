import argparse
import numpy as np
import os
from pymoab import core, tag, types


def parse_arguments():
    """
    Parse the argument list and return a mesh file location and an optional
    element type if the mesh file does not contain any hex elements.

    Input:
    ______
       none

    Returns:
    ________
       args: Namespace
           User supplied mesh file location and optional element type.
    """

    parser = argparse.ArgumentParser(description="Expand vector tags to scalar tags.")

    parser.add_argument("meshfile",
                        type=str,
                        help="Provide a path to the mesh file."
                        )
    parser.add_argument("-e", "--element",
                        type=str,
                        help="Provide a type of MB element other than hex."
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
           The type of MOAB element from which to extract the tag list.

    Returns:
    ________
       element_list: List
           A list of all specific elements in the mesh.
       scalar_tags: List
           A list of all scalar tags in the mesh.
       vector_tags: List
           A list of all vector tags in the mesh.
    """

    # Retrieve an arbitrary MBHEX element in the mesh and extract the tag list.
    root = mb.get_root_set()
    element_list = mb.get_entities_by_type(root, element)

    # If there are none of the specified mesh elements, print a warning and exit.
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


def create_database(mesh_file, mb_ref, mb_exp, hexes, scal_tags, vec_tag, length, name):
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
           A PyMOAB core instance with a loaded data file for expanding vector tags.
       hexes: List
           A list of all hex elements in the mesh.
       scal_tags: List
           A list of all scalar tags in the mesh.
       vec_tags: List
           A list of all vector tags in the mesh.
       length: int
           The length of the vector tag.
       name: str
           The handle of the vector tag.

    Returns:
    ________
       none
    """

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

    """
    For the vector tag on each element, retrieve the scalar value at a specific
    index and create a scalar tag. For each index, write the scalar tag value
    to disk in a vtk file in the specified database.
    """

    index = 0
    while index < length:
        scalar_data = []
        data = mb_exp.tag_get_data(vec_tag, hexes)
        scalar_data = np.copy(data[:,index])
        data_type = vec_tag.get_data_type()
        scalar_tag = mb_ref.tag_get_handle(name, 1, data_type, types.MB_TAG_SPARSE,
                                           create_if_missing = True)
        mb_ref.tag_set_data(scalar_tag, hexes, scalar_data)

        # Write the mesh file with the new scalar tag.
        file_location = os.getcwd() + "/" + dir_name + "/" + name + str(index) + ".vtk"
        mb_ref.write_file(file_location)
        index += 1

    print(str(index) + " files have been written to disk.")


def expand_vector_tags(mesh_file, element_type = None):
    """
    Load the mesh file and extract the lists of scalar and vector tags, then
    expand each vector tag.

    Input:
    ______
       mesh_file: str
           User supplied mesh file location.
       element_type: str
           MB element type. If one is not supplied, use hex.

    Returns:
    ________
       none
    """

    # Load the mesh file to create a reference mesh.
    mb_ref = core.Core()
    mb_ref.load_file(mesh_file)

    # Create a dictionary with the MB element types and their integer values.
    elements = {
        "vertex" : 0, "edge" : 1, "tri" : 2, "quad" : 3, "polygon" : 4,
        "tet" : 5, "pyramid" : 6, "prism" : 7, "knife" : 8, "hex" : 9,
        "polyhedron" : 10, "entityset" : 11, "maxtype" : 12
        }

    # Retrieve the lists of scalar and vector tags on the mesh.
    if element_type is None:
        try:
            hexes_ref, scal_tags_ref, vec_tags_ref = get_tag_lists(mb_ref, types.MBHEX)
        except LookupError:
            print("WARNING: No hex elements were found in the mesh.")
            exit()
    else:
        # Ensure the user entered a valid MB element type.
        type_int = elements.get(element_type.lower())
        if type_int is None:
            print("WARNING: Please choose a valid MB element type.")
            exit()
        else:
            try:
                hexes_ref, scal_tags_ref, vec_tags_ref = get_tag_lists(mb_ref, type_int)
            except LookupError:
                print("WARNING: No " + element_type + " elements were found in the mesh.")
                exit()

    # Make sure the mesh file contains at least one vector tag.
    if len(vec_tags_ref) < 1:
        raise LookupError("WARNING: This mesh file did not contain any vector tags.")

    # Delete each vector tag from the reference mesh.
    for tag in vec_tags_ref:
        mb_ref.tag_delete(tag)

    # Load the mesh file for extracting vector tag data.
    mb_exp = core.Core()
    mb_exp.load_file(mesh_file)

    # Retrieve the lists of scalar and vector tags on the mesh.
    if element_type is None:
        try:
            hexes_exp, scal_tags_exp, vec_tags_exp = get_tag_lists(mb_exp, types.MBHEX)
        except LookupError:
            print("WARNING: No hex elements were found in the mesh.")
            exit()
    else:
        # Ensure the user entered a valid MB element type.
        type_int = elements.get(element_type.lower())
        if type_int is None:
            print("WARNING: Please choose a valid MB element type.")
            exit()
        else:
            try:
                hexes_exp, scal_tags_exp, vec_tags_exp = get_tag_lists(mb_exp, type_int)
            except LookupError:
                print("WARNING: No " + element_type + " elements were found in the mesh.")
                exit()

    """
    for tag in vec_tags_exp:
        length = tag.get_length()
        name = tag.get_name()
        create_database(mesh_file, mb_ref, mb_exp, hexes_ref, scal_tags_ref, tag, length, name)
    """


def main():

    # Parse arguments.
    args = parse_arguments()

    # Expand the vector tags from the mesh file.
    try:
        expand_vector_tags(args.meshfile, args.element)
    except LookupError as e:
        print(str(e))
        exit()


if __name__ == "__main__":
    main()
