repotest
========
A simple utility to try and do some rough testing to see if a delorean
repository seems to work.

Can be used with Jenkins, the script will drop a repository.properties file to
be passed along to a parameterized job.

Example
=======

    ./repotest.sh http://trunk.rdoproject.org/liberty/centos7/current/delorean.repo
    06/10/2015-03:13:33 INFO: Downloading repository file from http://trunk.rdoproject.org/liberty/centos7/current/delorean.repo to /etc/yum.repos.d/delorean.repo ...
    [delorean]
    name=delorean-python-tempest-lib-f97b514e46cba9acd4f7f519aecc862693cde307
    baseurl=http://trunk.rdoproject.org/centos7-liberty/f9/7b/f97b514e46cba9acd4f7f519aecc862693cde307_225b76a0
    enabled=1
    gpgcheck=0
    priority=1
    06/10/2015-03:13:33 INFO: Testing against baseurl 'http://trunk.rdoproject.org/centos7-liberty/f9/7b/f97b514e46cba9acd4f7f519aecc862693cde307_225b76a0'.
    06/10/2015-03:13:33 INFO: Retrieved repository and baseurl checksum successfully.
    06/10/2015-03:13:33 INFO: Validating that installed repositories work ...
    06/10/2015-03:13:33 INFO: Running /usr/bin/yum clean all, makecache, repolist
    Loaded plugins: fastestmirror
    Cleaning repos: base delorean extras updates
    Cleaning up everything
    Loaded plugins: fastestmirror
    base                                                     | 3.6 kB  00:00:00
    delorean                                                 | 2.9 kB  00:00:00
    extras                                                   | 3.4 kB  00:00:00
    updates                                                  | 3.4 kB  00:00:00
    (1/15): delorean/filelists_db                            | 429 kB  00:00:00
    (2/15): delorean/primary_db                              | 137 kB  00:00:00
    (3/15): delorean/other_db                                |  32 kB  00:00:00
    (4/15): base/7/x86_64/group_gz                           | 154 kB  00:00:01
    (5/15): extras/7/x86_64/filelists_db                     | 322 kB  00:00:00
    (6/15): extras/7/x86_64/primary_db                       |  87 kB  00:00:00
    (7/15): extras/7/x86_64/prestodelta                      |  17 kB  00:00:00
    (8/15): extras/7/x86_64/other_db                         | 310 kB  00:00:00
    (9/15): base/7/x86_64/filelists_db                       | 6.0 MB  00:00:02
    (10/15): updates/7/x86_64/prestodelta                    | 242 kB  00:00:00
    (11/15): base/7/x86_64/primary_db                        | 5.1 MB  00:00:03
    (12/15): updates/7/x86_64/filelists_db                   | 2.7 MB  00:00:01
    (13/15): base/7/x86_64/other_db                          | 2.2 MB  00:00:03
    (14/15): updates/7/x86_64/primary_db                     | 4.0 MB  00:00:01
    (15/15): updates/7/x86_64/other_db                       |  25 MB  00:00:01
    Determining fastest mirrors
     * base: mirror.unl.edu
     * extras: mirror.oss.ou.edu
     * updates: centos.sonn.com
    Metadata Cache Created
    Loaded plugins: fastestmirror
    Loading mirror speeds from cached hostfile
     * base: mirror.unl.edu
     * extras: mirror.oss.ou.edu
     * updates: centos.sonn.com
    repo id              repo name                                                               status
    base/7/x86_64        CentOS-7 - Base                                                         8,652
    delorean             delorean-python-tempest-lib-f97b514e46cba9acd4f7f519aecc862693cde307    380
    extras/7/x86_64      CentOS-7 - Extras                                                       214
    updates/7/x86_64     CentOS-7 - Updates                                                      1,501
    repolist: 10,747
    06/10/2015-03:14:19 INFO: Package list for delorean
    Loaded plugins: fastestmirror
    Loading mirror speeds from cached hostfile
    Available Packages
    dib-utils.noarch                                 0.0.9-0.99.20150930.2010git.el7.centos      delorean
    diskimage-builder.noarch                         1.1.3-dev32.el7.centos                      delorean
    instack.noarch                                   0.0.8-dev4.el7.centos                       delorean
    instack-undercloud.noarch                        2.1.3-dev222.el7.centos                     delorean
    openstack-barbican.noarch                        1.0.0.0-rc2.dev6.el7.centos                 delorean
    openstack-barbican-api.noarch                    1.0.0.0-rc2.dev6.el7.centos                 delorean
    openstack-barbican-keystone-listener.noarch      1.0.0.0-rc2.dev6.el7.centos                 delorean
    [...]
    06/10/2015-03:14:19 INFO: Dumping repository configuration to in /home/centos/repository.properties ...
    06/10/2015-03:14:19 INFO: Finished validating repositories.
    06/10/2015-03:14:19 INFO: Cleaning up ...
    Loaded plugins: fastestmirror
    Cleaning repos: base extras updates
    Cleaning up everything
    Cleaning up list of fastest mirrors
