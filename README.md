# UNICEF Philippines Data Migrations
These database migrations can be used to set up the data warehouse for UNICEF Philippines.
Changes to this data warehouse should be added to this sqitch project as new migrations.

## Testing Database migrations

This repo has been set up to automatically run database migration tests using sqitch on CircleCI.  This is to ensure that no PR with failing migrations is overlooked.
### Testing Database migrations locally

To test locally, you need the following:

First, bring up a docker container:

```sh
docker-compose up -d
```

> Note that the `docker-compose.yml` file assumes there isn't an existing Postgres database on the `:5432` port.

Once you are done with the above, you can run sqitch tests!

To run tests manually, do the following:

```sh
sqitch deploy sqitch_test && sqitch verify sqitch_test && sqitch revert -y sqitch_test
```

You can also alternatively use the [CircleCI Local CLI](https://circleci.com/docs/2.0/local-cli/) to run tests.
