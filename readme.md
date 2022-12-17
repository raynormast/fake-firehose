# Fake Firehose
This project generates the mythical "firehose" relay that small Mastodon instances look for,
at least to get content.

It's a little crazy.

Find a better way to do it and issue a pull request, or just tell me where your new repo is :)

## How to run it

Make sure you have `jq` installed.

Linux:
`apt install jq`

macOS:
`brew install jq`

### 1. Fake Relay is Setup
You need to have [fakerelay](https://github.com/g3rv4/FakeRelay) running and hooked up with your Mastodon instance.

[Gervasio](https://mastodonte.tech/@g3rv4) is _the man_ for fakerelay.

### 2. Environmental variables
You need to have two environmental variables set:

- fakeRelayHost
- fakeRelayKey

I recommend you put them in your `.bashrc` file. I use:

```shell
export fakeRelayKey="MrNtYH+GjwDtJtR6YCx2O4+TuldQ_SOMEKEY_aVni0rsbDryETCx9lHSZmzcOAv3Y8+4LiD8bFUZbnyl4w=="
export fakeRelayHost="https://my-relay.raynor.haus/index"
```

### 3. Instances you want to follow
Create a file `domains` and put once instance on each line that you want to follow. The top 50 by total accounts by what my instances sees is included.

### 4. Start it up
Open a terminal and run `./start-firehose.sh`

This starts reading the public federated statuses stream of every instance in the `domains` file.

Open a different terminal and run `./run-firehose.sh`

This starts feeding the statuses to fakerelay.

Profit.

### 5. How to stop it
Log out.

No for real, I didn't get to that part yet.

# Super important things to watch out for
**AFTER YOU RUN `start-firehose.sh` IT WILL KICK OFF A SHELL SCRIPT IN THE BACKGROUND FOR EVERY DOMAIN YOU HAVE LISTED. THERE IS NO EASY WAY TO KILL THESE.**

100% for real, run this in a VM or a container or somewhere you can log out if you overdid it to start.

`run-firehose.sh` has a couple of important lines to look at.

First: 

`until [ $curls -lt 100 ]` 

determines the _total_ number of `curl` executables that can be ran at once, system-wide. This includes one for each `domain` you have listed.

If your curl limit is less than your domains number, than nothing will flow.

If your curl limit is too high, your machine will run out of resources and lock up.

Second: 

`until [ $linesLeft -gt 500 ]` 

sets how many statuses (aka posts, toots) have to be in a batch. **YOU NEED TO BATCH THESE** 

_Most_ of the URIs will be duplicated, the beginning of `run-firehose.sh` de-duplicates the URIs. 500-1000 has been a good batch size in my experience. 