# AmqpReader

Consume AMQP messages and write each payload to its own file ("msg-00000")

By default this is a non-destructive read of the queue unless the `--ack` flag is passed.  

When all messages have been read, the app will exit unless the `--tail` flag is passed. 
When the queue is empty it will poll at `--poll` frequency.

Will read all messages unless `--max <count>` parameter is passed and will enter a polling state until this count is reached.

### Install

``` sh
$ mix deps.get
$ mix escript.build
```

### Usage

``` sh
# Start amqp_reader

# consumes messages from the specified queue and writes each to its own file
#
$ ./bin/amqp_reader \
    --uri amqp://<user>:<password>@localhost:5672/<vhost> \
    --queue <name> \
    --dir <directory name>
```

### Command Line Options

- `uri` - (required, str) URI of AMQP host and virtual host to reference
- `queue` - (required, str) Name of queue to read from
- `dir` - (optional, str, default: ".") Directory path to write messages to
- `max` - (optional, int) Maximum number of messages to read
- `tail` - (optional, bool) keep running after all message have been consumed, writing new messages as they arrive
- `poll` - (optional, int, default: 1 second) Millisecond poll period when queue is empty.
- `ack` - (optional, bool) consumed messages are `acked` and will be removed from queue 
