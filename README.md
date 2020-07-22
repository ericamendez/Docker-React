This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

# Creating Production Grade Workflow

## Things I Learned:
### Containerizing React App
- How to build image in React app by adding a `Dockerfile.dev` file in root directory and running the command `docker build -f Dockerfile.dev .` with the flag -f specifying the file we will use to build out the image.


### Docker Volumes
- Setting up Docker volumes to allow the docker container to reference files in my local machine, (and update changes immediately when made on my local machine). First build the image `docker build -f Dockerfile.dev` then run command `docker run -it -p 3000:3000 -v /app/node_modules -v ${pwd}:/app CONTAINER_ID`
    - `-v /app/node_modules` putting a bookmark on the node_modules folder (placeholder for a folder that is inside the container)
    - `-v ${pwd}:/app`
        - `-v` used to set up a volume
        - `$(pwd)` shortcut to the path of present working directory in machine
        - `:` we are saying we want to map up a folder outside a container to a folder inside a container
- How configure docker volumes in `docker-compose.yml` file so that we won't have to run the long command mentioned above. We could just do that all in docker-compose and run `docker-compose up` to build image and run it.


### Running React Test
- Build React app & run test in Docker with `docker -it <CONTAINER_ID> npm run test` command.
- Since we have a container created specifically to run test, we need to set up volume stuff in this container as well so that we can live update test. How to fix that:
    - Run the test inside of our docker-compose instance (that already has that the volumes mappings set up). (need to remember the container id)
        - `docker-compose up`
        - `docker ps` and get container id
        - `docker exec -it <CONTAINER-ID> npm run test`
    - Add second service to `docker-compose.yml` file that is solely responsible for running our test suite (get all the output of test log in interface of docker-compose, also we won't be able to manipulate the running test suite)
        - `test:
               build: 
                   context: .
                   dockerfile: Dockerfile.dev
               volumes:
                   - /app/node_modules
                   - .:/app
               command: ["npm", "run", "test"]`
        - Run with `docker-compose up --build`

### Building React App in Production
- In development environment we have a dev server that sends the http request the `index.html` and `main.js` files to the browser. In production, this dev server does not exist because it is not appropriate to be running in production environment (has a lot of proccessing power dedicated to processing constantly changing `index.html` and `main.js` files, which we will not need in production since we aren't making changes).
- We will use server nginx, takes incoming traffic and routing to it with some static files. 
- Create a seperate Dockerfile that will create a production version of our web container with a nginx server.
    - docker hub has a nginx image, we will be doing a multi step build process for our production container.

### Continuous Integration (with Travis CI) and Deployment with AWS
- I will be using Travis CI so I configured a `.tavis.yml` file to let Travis know we want docker installed and specify the series of commands to execute before the test are ran.
- The project was deployed using AWS Elastic Beanstalk (easiest way to get started with production docker instances). 
    - Create new application, create web server environment (platform: docker), (IF YOU LEAVE THESE INSTANCES UP YOU WILL BE BILLED MONEY FOR IT, MAKE SURE TO SHUT IT DOWN)
    - Elastic Beanstalk Workflow: http request -> AWS Environment: Load Balancer route reuest -> Virtual Machine that is running Docker with our application inside of it.
        - Elastic Beanstalk monitors the amount of traffic coming in to VM. When that traffic reaches a certain threshhold, EB will automatically add in additional VM's to handle that traffic. 
        - Load Balancer will find the VM with the least amount of traffic and route the request to that machine.
        - Benefit is that EB automatically scales everything up for us.
    - Configure `.travis.yml` to add deploy instructions (notes in files).


REMINDER TO DELETE RESOURCES CREATED IN EBS OR YOU WILL BE CHARGED AWS BILL
1. Go to the Elastic Beanstalk dashboard.

2. In the left sidebar click "Applications"

3. Click the application you'd like to delete.

4. Click the "Actions" button and click "Delete Application"

5. You will be prompted to enter the name of your application to confirm the deletion.