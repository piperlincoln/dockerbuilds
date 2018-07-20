# Docker for Mac OS


1. To build a container in docker, use the following format:

    ```
    docker build -t [CONTAINER NAME] -f [FILE NAME] [LOCATION]
    ```
2. To enter a container in docker, use the following format:

    ```
    docker run -it --name=[IMAGE NAME] [CONTAINER]
    ```
    
    You also have the option of pulling files from your local machine into the container by adding this flag:
    
    ```
    -v LOCAL/FOLDER:DOCKER/LOCAL/FOLDER
    ```
    
    Change the path to reflect what files you would like from your machine and where you would like them in docker.
    
3. If you have previously entered a container with a specific image name, you cannot reuse that name. To remove it, use the following format:

    ```
    docker rm [IMAGE NAME]
    ```
    
    If you would like to remove a container, use the following format:
    
    ```
    docker rmi -f [CONTAINER NAME]
    ```
    
4. If you want to save your work, you can commit the container using the following format:

    ```
    docker commit -m "MESSAGE"  [IMAGE NAME] [CONTAINER NAME]
    ```
    
5. To see a list of your docker containers, use the following command:

    ```
    docker images
    ```
    
********************************************************************************************************************************************
    
6. In order to launch VisIt in your container, run the following command on your local machine first:

    ```
    xhost + 127.0.0.1
    ```
    
    Make sure you have an updated version of XQuartz running.
    
    The following variables under the "Security" tab in Preferences should be toggled.
    
    <img src="https://s33.postimg.cc/mygpjszn3/githubpic.png)" width="400" height="200"/>
    
    
7. Build your container with the visit.dockerfile script provided.
    
8. When you run your container, add the following flags to the command:

    ```
    -e DISPLAY=docker.for.mac.localhost:0 -v /tmp/.X11-unix:/tmp/.X11-unix:rw
    ```
    
    Once in your container, you should be able to launch the VisIt GUI.
    
    
    
    
    
