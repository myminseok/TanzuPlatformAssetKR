# node-express

This is a starter ExpressJs project, you can run it as a standalone
app using `npm run server` in the root of the project.
The server will be listening to request on port `3000`,
so you can test the server in a browser accessing `http://localhost:3000` or via `cURL`.

Before running the command `npm run server` you need to run `npm install` to
install the dependencies

https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-nodejs-nodejs-buildpack.html


npm ci --cache npm-cache
tanzu apps workload apply -f config/workload.yaml -n my-space --local-path . --source-image infra-harbor.lab.pcfdemo.net/regops/node-express --registry-ca-cert /data/tapconfig/tkg-custom-ca.crt -y
