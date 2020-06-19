# vbrew
Script that should help alleviate pain of installing older brew formulas.

## Why vbrew?
`brew` does not currently support the installation of older formula versions. 
This is a solution to that problem.
Additionally, older formula versions are using a SHA256 that might no longer work
for the current version of your OS. `vbrew` will correct the SHA256 should this happen.

## First time use
Assumes you are using SSH to clone, https support needs to be added.

Clone `vbrew`

    git clone git@github.com:mvaal/vbrew.git vbrew

Run

    ./vbrew.sh

Add `vbrew` alias to your profile. The alias will print after first run.

    alias vbrew="<repo-path>/vbrew.sh"

## Usage
Other than installing specific formula versions, vbrew proxies all other calls to `brew` so you
can use it as if you were using `brew` itself

    vbrew install terraform 0.12.24
    vbrew uninstall terraform # Same as calling brew uninstall terraform

Running the `install` command will automatic switch to the older version.
