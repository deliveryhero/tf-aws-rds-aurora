# A simple example

This example will show the bare minimum parameters to create a Serverless V2 PostgreSQL Aurora cluster.

In general setup of the PostgreSQL serverless v2 cluster is very similar to creation of a regular PostgreSQL cluster.
The only crucial differences are the following:
* `engine_mode` needs to be specified and set to `provisioned`
* `instance_type` is to be set to `db.serverless`
* Scaling params are to be set in `serverlessv2_min_capacity` and `serverlessv2_max_capacity` params. 