# Fake Firehose
This project is basically a shell/bash/text frontend for [fakerelay](https://github.com/g3rv4/FakeRelay)

It allows instances to fill their federated timelines from other instances that have public timelines.

You can find the fakefirehose author at [@raynor@raynor.haus](https://raynor.haus/@raynor)

## How to run it

In the config folder there are three files

- domains-federated
- domains-local
- hashtags

If you want the full on public feed from an instance, put it in the domains-federated file, one domain per line.

If you only want the local feed from an instance, put it on the domains-local file, one domain per line.

If you want to follow a hash tag you either either add a hashtag after an instance in `domains-federated` or `domains-local`

For example: if in `domains-fedarated` you put `mastodon.social #JohnMastodon` a stream will open to watch for the hashtag #JohnMastodon on the public
stream from mastodon.social

Another example:  if in `domains-local` you put `infosec.exchange #hacker` a stream will open to watch for the hashtag #hacker on the _local_ stream from infosec.exchange

## Docker
To run it in docker -- recommended

1. Make sure you have [docker installed](https://docs.docker.com/engine/install/).
2. From your shell: create a directory, it is recommended that you give it a relevant name
3. Go into that directory and use `git clone https://github.com/raynormast/fake-firehose.git`
4. Go into the created directory: `cd fake-firehose`
5. `sudo docker build -t fakefirehose .`
6. Edit your `docker-compose.yml` file as needed. **The biggest thing** is to watch the volumes. It is _highly_ recommended that you keep your data directory in the parent directory, and NOT the directory the git repo is in.
7. Edit your `.env.production` file. The file is fairly well commented.
8. Run `sudo docker compose -f docker-compose.yml`

The entire thing should look something like:
```
cd ~
mkdir MastodonFireHose
cd MastodonFirehose
git pull https://github.com/raynormast/fake-firehose.git
cd fake-firehose
docker build -t fakefirehose .
# Edit your docker-compose and .env.production here
sudo docker compose -f docker-compose.yml up -d
```

# Configuration

## tl;dr
Your `./config` folder has three sample files, after editing you should have the following three files:
```
domains-federated
domains-local
hashtags
```

**In each file, comments begin with `##` not the tradional single `#`.**

The syntax is the same for the domains files:
```
## Follow full timeline
mastodon.instance

## Follow these hashtags from the timeline
mastodon.instance #mastodon #relay
```

The files are well commented.


## domains-federated file
This file has the full federated feeds of any instances you want fed to fakerelay. 

Each line of the file should have the domain name of an instance whose federated timeline you want to follow.
I.e.,
```
raynor.haus
infosec.exchange
```

This can generate a LOT of posts if you choose a large instance.

For example, if you use `mastodon.social` or `mas.to` you can expect your server to fall behind. `mastodon.social` generates 50,000 - 200,000 posts on the federated timeline per day.

It is recommended that you only use this file to:
- follow hashtags
- follow instances with small federated timelines, with content you want in yours

#### domains-federated hashtags
The one time to use the federated timeline is to catch most posts with a specific hashtag. 

Every word after after an instance domain is a hashtag to relay.

Example:

`mastodon.social fediblock fediverse mastodev mastoadmin`

Will only return posts from the mastodon.social federated feed with hashtags of `#fediblock`, `#fediverse`, 
`#mastodev`, and `#mastoadmin`.

The `#` is optional -- it is accepted simply to make the file more intuitive.

## domains-local file
This file is identical to the `domains-federated` file except that it only recieves posts created on
_that_ instance (the local timeline). 

It is possible to keep up with the larger instances, such as `mastodon.social` if you only look at the
local timeline.


## hashtags file
If you put ANY hashtags in here a stream will be opened for _every_ host in the `domains-federated` and `domains-local` file.

**It's purpose is for people or instances that want to find nearly every post with a particular hashtag**

_It can very quickly open up a lot of `curl` streams_

### Example
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
https://mastodon.social/api/v1/streaming/public
https://mas.to/api/v1/streaming/public
https://aus.social/api/v1/streaming/public/local
https://mastodon.nz/api/v1/streaming/public/local
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
there would 5 x 5 x 3 = 75 new streams. 

Usually a more targeted approach is better.

It is recommended that you put hashtags in your `domains-federated` or `domains-local` files.

Your humble author's federated file currently looks like this:
```
mastodon.social infosec hacker hackers osint hive lockbit hackgroup apt vicesociety

mastodon.social blackmastodon blackfediverse poc actuallyautistic neurodivergent blacklivesmatter freechina  antiracist neurodiversity  blackhistory bipoc aapi asian asianamerican pacificislander indigenous native

mastodon.social fediblock fediverse mastodev mastoadmin
mastodon.social apple politics vegan trailrunning church churchillfellowship christianity christiannationalism
```

My `domains-local` file is:
```
## Fake Firehose will only take local posts from these domains

mastodon.social
universeodon.com

## International English (if you aren't from the US) ###
## mastodon.scot
aus.social
mastodon.nz
respublicae.eu
mastodon.au

### Tech ###
partyon.xyz
infosec.exchange
ioc.exchange
tech.lgbt
techhub.social
fosstodon.org
appdot.net
social.linux.pizza

journa.host
climatejustice.social
```

This generates an acceptable stream of posts for my federated timeline. The tags I follow on mastodon.social
are those that are either few in number overall, or are harder to find on local timelines.

## .env.production
tl;dir, This file is fairly well commented internally, just go at it.

**The sample file probably does not need any changes beyond your fakerelay information**

### options
#### fakeRelayKey
This needs to have the key you generated with fakerelay.

_Example_:
`fakeRelayKey="MrNtYH+GjwDtJtR6YCx2O4dfasdf2349QtZaVni0rsbDryETCx9lHSZmzcOAv3Y8+4LiD8bFUZbnyl4w=="`


#### fakeRelayHost
The full URL to your fakerelay

_Example_:
fakeRelayHost="https://fr-relay-post.myinstance.social/index"

#### runFirehose
This controls whether the posts will actually be sent to your relay, or only collected in your /data folder.
You almost certainly want this set at: 

`runFirehose=true`

The _only_ reason to set it to `false` is for debugging, or logging posts from the fediverse.

#### maxCurls and minURIs
These two options are closely related. `maxCurls` is the maximum number of `curl` processes you want to have
running on your system at once. If you follow timelines with a lot of posts, you may need to limit this.

**Note** This always needs to be higher that the total number of instances + hashtags you have configured, because each one of those is a separate `curl` process

fake-firehose batches posts to de-duplicate them, `minURIs` is the size of that batch. If you have a lot of
_federated_ posts coming in you will want to set this to a high number because a lot of them will be duplicates.

If you only use local timelines it doesn't matter, you will not have any duplicates.

It is a tradeoff between resources (and `curl` processes running) and how quickly you want to fill your
instance's federated timeline.

_Example for a moderate number of incoming posts_:
```
## Max curl processes have not gotten out of control so this is absurdely high.
maxCurls=2000

## Nearly all of the timelines I follow are local, so there are very few duplicates.
minURIs=10
```

#### archive
Archive mode will save the json stream but not parse it, not even into URIs.
This will greatly save resources, but obviously will not send it to
the relay.

**The only reasons to use this is for debugging or logging posts from servers**.

You almost certainly want this set at:

```archive=false```

#### restartTimeout
This is how long the docker image will run before exiting. As long as your `docker-compose` has `restart: always` set this simply restarts the image to kill any hung `curl` processes.

The only reason to set it high is if you have a lot of timelines you follow. Each one takes time to open up,
so if you restart often you will miss more posts.

_Example:_

`restartTimeout=4h`

#### streamDelay
This is only for debugging.

Keep it at:

`streamDelay="0.1s"`

# Data Directory
Data is saved in the format of:
```
"%Y%m%d".uris.txt
```

In archive mode the format is:
```
"/data/"%Y%m%d"/"%Y%m%d".$host.json"
```

For example, if you set `archive=true` and had `mastodon.social` in your `domains-federated` or `domains-local` config, on January 1st, 2023 the json stream would be saved at
```
/data/20230101.mastodon.social.json
```

# Misc
## Backoff
An exponential backoff starts if `curl` fails. It is rudimentary and maxes out at 15 minutes.

## DNS lookup
Before a URL starts streaming fakefirehose will look up the DNS entry of the host. If it fails,
the stream will not begin, _and will not attempt to begin again_ until the container is restarted.

## Permissions
The permissions of the outputted data files will be set to `root` by default. This will get fixed
in a future release.

# Why fake firehose?
When I wrote this there were not other options I was aware of to fill a federated timeline of a small instance.
The work of [Gervasio Marchand](https://mastodonte.tech/@g3rv4) is fantastic but still required programming knowledge to make use of.

I wanted the simplest setup and config I could create, without setting up an entirely new web UI.

There are a lot of things to do better, I'll work on the ones I have time and capability for. Otherwise, this project
is practically begging to be re-written in python or something else.