# SIMP-Builder

A lightweight, highly repeatable SIMP build environment.

## Usage

 1. Download the latest CentOS DVD and place it in the root of this directory
 2. From the root of this directory, execute **`docker build ./`**
    The Dockerfile takes the optional arguments `BRANCH` and `BASE_ISO` (specified with `--build-arg VAR=value`)
	    * `BRANCH` is used to select the Git branch of the [simp-core](https://github.com/simp/simp-core) repository. Default: `5.1.X`
		* `BASE_ISO` is the name of the CentOS image file. Default: `CentOS-7-x86_64-DVD-1511.iso`
 3. Run the generated Docker image in interactive mode with `--priviliged`
 4. Execute the build command using the `BRANCH` and `BASE_ISO` that were specified for `docker build` (or the defaults)
 5. Copy the SIMP ISO out of the Docker container
 6. (Optional) Destroy the container

### Full example

```shell
cd $path_to_this_repo
wget http://mirrors.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1511.iso
# The ISO should be verified against the CentOS GPG key at this point. See the CentOS documentation for details.
docker build ./
docker run --priviliged -ti $IMAGE_ID
bundle exec rake build:auto[5.1.X,/home/simp_builder/base_image/CentOS-7-x86_64-DVD-1511.iso]
# From a second terminal
docker cp $CONTAINER_ID:/home/simp_builder/simp-core/SIMP_ISO /destination/path
```

## Notes

Mock requires the `unshare()` syscall to execute, which in Docker requires special priviliges, i.e, the `--priviliged` flag.  Unfortunately the `build1 sub-command does not currently support this flag (see docker/#1916), requiring us to use the multi-step process above.  Once the functionality is available, this should become much simpler, i.e, `docker build` could work somewhat like a function, returning an image file.
