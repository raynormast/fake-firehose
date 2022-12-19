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

If you want to follow a hash tag you either either add a hashtag after an instance in `domains-federated` or `domains-local`

For example: if in `domains-fedarated` you put `mastodon.social #JohnMastodon` a stream will open to watch for the hashtag #JohnMastodon on the public
stream from mastodon.social

Another example:  if in `domains-local` you put `infosec.exchange #hacker` a stream will open to watch for the hashtag #hacker on the _local_ stream from infosec.exchange

## Docker
Build docker

Run docker

### The hashtags file
If you put ANY hashtags in here a stream will be opened for _every_ host in the `domains-federated` and `domains-local` file.

Example:
`domains-federated` content:

```
mastodon.social
mas.to
```

`domains-local` content:

```
aus.social
mastodon.nz
```

`hashtags` content:
```
JohnMastodon
Mastodon
```

will result in the following streams all opening:
```shell
https://mastodon.social/api/v1/streaming/hashtag?tag=JohnMastodon
https://mas.to/api/v1/streaming/hashtag?tag=JohnMastodon
https://aus.social/api/v1/streaming/hashtag?tag=JohnMastodon
https://mastodon.nz/api/v1/streaming/hashtag?tag=JohnMastodon
https://mastodon.social/api/v1/streaming/hashtag?tag=Mastodon
https://mas.to/api/v1/streaming/hashtag?tag=Mastodon
https://aus.social/api/v1/streaming/hashtag?tag=Mastodon
https://mastodon.nz/api/v1/streaming/hashtag?tag=Mastodon
```

If you had a total of 5 lines in `domains-federated` and `domains-local` plus 3 entries in `hashtags`
there would 5x5x3 = 75 new streams.

I mean, you can do it, but you won't need your central heating system any more.