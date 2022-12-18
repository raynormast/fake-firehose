# Fake Firehose
This project generates the mythical "firehose" relay that small Mastodon instances look for,
at least to get content.

It's a little crazy.

Find a better way to do it and issue a pull request, or just tell me where your new repo is :)

## How to run it

In the config folder there are three files

- domains-federated
- domains-local
- hashtags

If you want the full on public feed from an instance, put it in the domains-federated file, one domain per line

If you only want the local feed from an instance, put it on the domains-local file, one domain per line

If you want to follow a hashtag you're out of luck because I didn't get that far. But it will go into the hashtags file.

Build docker

Run docker