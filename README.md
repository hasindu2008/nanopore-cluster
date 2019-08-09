# nanopore-cluster

### Required Hardware

A cluster of computers connected to each other using Gigabit Ethernet.

We built our cluster using 16 Rock64 development boards and the list of items we used are :
- Rock64 dev boards (4GB RAM)
- Rock64 Heatsinks
- 64 GB eMMC modules
- USB to type H barrel 5V DC Power Cable
- Orico DUB-8P-BK USB charging stations (as power supplies for Rock64)
- Copper Cylinders for Raspberry Pi
- HPE OfficeConnect 1950 24G 2SFP+ 2XGT Switch
- Ethernet Cables
- USB Adapter for eMMC Module (to flash eMMC)


### Connecting nodes together

- Build the cluster
  - connect the nuts and bolts (Using copper cylinders)
  - Flash Linux distributions onto eMMCs (we used Ubuntu)
  - Plug eMMCs and heat sinks to the Rock64s
  - Connect Rock64s onto the Switch and power supplies


- Configure the switch
  - Assigning IP addresses to the Rock64s
  - Providing Internet to the Rock64s


### Setting up the *head node*

The node which will be used to control, connect and assign work to the other *worker nodes* is referred to as the *head node*.  This *head node* can be a Rock64 it self or any other computer. We used an old PC as the *head node*. On the head node you may want to do the following.

- Install and configure [*ansible*](https://docs.ansible.com/ansible/latest/index.html). *Ansible* will be used to launch commands on all *worker nodes*, centrally from the *head node*.
  - install *ansible*. On Ubuntu:
    ```bash
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt update
    sudo apt install ansible
    ```
  - configure *ansible*.
    You need to edit your `/etc/ansible/ansible.cfg` and `/etc/ansible/hosts`. Our sample config files are at [scripts/sample_config/ansible](scripts/sample_config/ansible).


- Create an SSH key on the head node. You can use the command `ssh-keygen`. This key is needed for password-less access to the *worker nodes*.

- Mount the network attached storage. You can add an entry to the `/etc/fstab` for persist across reboots.

- Optionally, you can install *ganglia* to monitor various metrics of the nodes. In Ubuntu you may use :

  ```bash
  sudo apt-get install ganglia-monitor rrdtool gmetad ganglia-webfrontend
  sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf

  ```

  You have to edit the configuration files `/etc/ganglia/gmetad.conf`  and /etc/`ganglia/gmond.conf`. Our sample config files are at [scripts/sample_config/ganglia](scripts/sample_config/ganglia). In summary commands are :

  You may refer [here](https://hostpresto.com/community/tutorials/how-to-install-and-configure-ganglia-monitor-on-ubuntu-16-04/) for a tutorial on installing and configuring ganglia.

- Optionally, you can configure *rsyslog* and [LogAnalyzer](https://loganalyzer.adiscon.com/) centrally view the logs through web browser.

- Add path of  scripts/system to PATH

### Compiling software and preparing the folder structure

On one of your nodes (rock64 devices):

- compile the software. We compiled minimap2, nanopolish, samtools and f5c for ARM architecture.
- create folder named `nanopore` under `/`.
- Put compiled binaries to a folder named `/nanopore/bin`.
- Put the reference genome and a minimap2 index under `/nanopore/reference`.
- Create a folder named `/nanopore/scratch` for later use.

The directory structure should look like bellow :

  ```
  nanopore
  ├── bin
  │   ├── f5c
  │   ├── minimap2-arm
  │   ├── nanopolish
  │   └── samtools
  ├── reference
  │   ├── hg38noAlt.fa
  │   ├── hg38noAlt.fa.fai
  │   └── hg38noAlt.idx
  └── scratch

  ```

### Setting up *woker nodes*

  On the *worker node*

  - change device name
  - change the time zone (and configure ntp)
  - apt update and package installation  eg: nfs-common ganglia-monitor
  - mount the network attached storage
  - Create a swap space
  - copy the binaries and the folder structure we constructed before.

  [shell script](scripts/new_workernode_setup/run_on_workernode.sh)  

  On the *head node*

  - copy ssh-key to the *worker node*
  - copy *ganglia* configuration files to the *worker node*
  - copy *rsyslog* configuration files to the *worker node*

  [shell script](scripts/new_workernode_setup/run_on_headnode.sh)  
