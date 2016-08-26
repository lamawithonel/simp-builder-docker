FROM centos:7

LABEL name="simp_builder"                      \
      vendor="Onyx Point, Inc."                \
	  description="SIMP ISO build environment" \
      build-date="20160725"

# The basename of the base ISO.  This should be located in the build directory.
ARG BASE_ISO=CentOS-7-x86_64-DVD-1511.iso

# The version branch of simp-core to use.
ARG BRANCH=5.1.X

RUN yum install -y epel-release
RUN yum upgrade -y
RUN yum install -y mock rpmdevtools rpm-sign genisoimage createrepo git which patch libyaml-devel glibc-headers autoconf gcc-c++ glibc-devel patch readline-devel zlib-devel libffi-devel openssl-devel make bzip2 automake libtool bison sqlite-devel libxml2-devel libxslt-devel clamav-update

RUN /usr/sbin/useradd -mG mock simp_builder

RUN /bin/mkdir /home/simp_builder/base_image
COPY $BASE_ISO /home/simp_builder/base_image/
RUN /bin/chown simp_builder:simp_builder -R /home/simp_builder/base_image

USER simp_builder
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
WORKDIR /home/simp_builder

RUN /usr/bin/gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN /usr/bin/curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer
RUN /usr/bin/curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer.asc
RUN /usr/bin/gpg --verify rvm-installer.asc && bash ./rvm-installer stable

RUN /bin/bash -l -c 'rvm install 2.1'
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc -v '~> 1.10.0'"

RUN /usr/bin/git clone https://github.com/simp/simp-core.git /home/simp_builder/simp-core
WORKDIR /home/simp_builder/simp-core

RUN /usr/bin/git checkout $BRANCH
RUN /bin/bash -l -c 'bundle install'

RUN /bin/echo "Please run the generated image, then execute \"bundle exec rake build:auto[${BRANCH},/home/simp_builder/base_image/${BASE_ISO}]\""

ENTRYPOINT /bin/bash -l
