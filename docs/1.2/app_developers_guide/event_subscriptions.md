# Subscribing to Events

As blocks are committed to the blockchain, an application developer may
want to receive information on events such as the creation of a new
block or switching to a new fork. This includes application-specific
events that are defined by a custom transaction family.

Hyperledger Sawtooth supports creating and broadcasting events. Event
subscription allows an application to perform the following functions:

-   Subscribe to events that occur related to the blockchain
-   Communicate information about transaction execution back to clients
    without storing that data in state
-   Perform event catch-up to gather information about state changes
    from a specific point on the blockchain

An application can react immediately to each event or store event data
for later processing and analysis. For example, a
[state delta processor](#sawtoothstate-delta) could store state data in a
reporting database for analysis and processing, which provides access to state
information without the delay of requesting state data from the validator. For
examples, see the [Sawtooth Supply
Chain](https://github.com/hyperledger/sawtooth-supply-chain) or
[Sawtooth
Marketplace](https://github.com/hyperledger/sawtooth-marketplace)
repository.

This section describes the structure of events and event subscriptions,
then explains how to use the validator's [ZeroMQ](http://zeromq.org)
messaging protocol (also called ZMQ or 0MQ) to subscribe to events.

>
> Note
>
> Web applications can also subscribe to events with a web socket
> connection to the REST API, but there are several limitations for this
> method. For more information, see
> [Web Socket Event Subscription](#about-web-sockets-and-event-subscriptions)

## About Sawtooth Events

Sawtooth events occur when blocks are committed \-\-- that is, the
validator broadcasts events when a commit operation succeeds \-\-- and
are not persisted in state. Each transaction family can define the
events that are appropriate for its business logic.

An event has three parts:

-   Event type (the name of the event)
-   Opaque payload whose structure is defined by the event type
-   List of attributes

An attribute is a key-value pair that contains transparent metadata
about the event. The key is the name of the attribute, and the value is
the specific contents for that key. The same key can be used for
multiple attributes in an event.

It is important to define meaningful event attributes, so that the
attributes can be used to filter event subscriptions. Note that although
attributes are not required, an event filter cannot operate on an event
without attributes. For more information, see
[About Event Subscriptions](#about-event-subscriptions).

Events are represented with the following protobuf message:

```protobuf
message Event {
  // Used to subscribe to events and servers as a hint for how to deserialize
  // event_data and what pairs to expect in attributes.
  string event_type = 1;

  // Transparent data defined by the event_type.
  message Attribute {
    string key = 1;
    string value = 2;
  }
  repeated Attribute attributes = 2;

  // Opaque data defined by the event_type.
  bytes data = 3;
}
```

The `event_type` field (the name of the event) is used to determine how
opaque (application-specific) data has been serialized and what
transparent event attributes to expect.

For more information, see [Events and Transaction
Receipts]({% link docs/1.2/architecture/events_and_transactions_receipts.md %}).

## Event Namespace

By convention, event names use the transaction family as a prefix, such
as `xo/create` for a create event from the XO transaction family.

Core Sawtooth events are prefixed with `sawtooth/`. The core events are:

> -   `sawtooth/block-commit`
> -   `sawtooth/state-delta`

### sawtooth/block-commit

A `sawtooth/block-commit` event occurs when a block is committed. This
event contains information about the block, such as the block ID, block
number, state root hash, and previous block ID. It has the following
structure:

```protobuf
Event {
  event_type = "sawtooth/block-commit",
  attributes = [
    Attribute { key = "block_id", value = "abc...123" },
    Attribute { key = "block_num", value = "523" },
    Attribute { key = "state_root_hash", value = "def...456" },
    Attribute { key = "previous_block_id", value = "acf...146" },
  ],
}
```

### sawtooth/state-delta

A `sawtooth/state-delta` occurs when a block is committed. This event
contains all state changes that occurred at a given address for that
block. This event has the following structure:

```python
Event {
  event_type = "sawtooth/state-delta",
  attributes = [Attribute { key = "address", value = "abc...def" }],
  event_data = <bytes>
}
```

Note that the addresses that match the filter are in the attributes.
Changed values are part of the event data.

### Example: An Application-specific Event

The XO transaction family could define an `xo/create` event that is sent
when a game has been created. The following examples show a simple
`xo/create` event in several languages.

Python example:

```python
context.add_event(
    "xo/create", {
        'name': name,
         'creator': signer_public_key
 })
```

Go example:

```
 attributes := make([]processor.Attribute, 2)
 attributes = append(attributes, processor.Attribute{
   Key:   "name",
   Value: name,
 })
 attributes = append(attributes, processor.Attribute(
   Key:   "creator",
   Value: signer_public_key,
 })
 var empty []byte
 context.AddEvent(
   "xo/create",
   attributes,
   empty)
```

JavaScript example:

```javascript
 context.addEvent(
   'xo/create',
   [['name', name], ['creator', signer_public_key]],
   null)
```

Rust example:

```rust
 context.add_event(
   "xo/create".to_string(),
   vec![("name".to_string(), name), ("creator".to_string(), signer_public_key)],
   vec![].as_slice())
```

## About Event Subscriptions

An application can use event subscriptions to tell the validator to
supply information about changes to the blockchain.

An event subscription consists of an event type (the name of the event)
and an optional list of filters for this event type. If an event is in
one of your subscriptions, you will receive the event when the validator
broadcasts it.

An event is "in a subscription" if the event's `event_type` field
matches the subscription's `event_type` field, and the event matches any
filters that are in the event subscription. If multiple filters are
included in a single subscription, only events that pass *all* filters
will be received. Note, however, that you can have multiple
subscriptions at a time, so you will receive all events that pass the
filter or filters in each subscription.

### Event Filters

An event filter operates on event attributes. A filter specifies an
attribute key, a \"match string\", and a filter type.

> -   The attribute key specifies the event attribute that you are
>     interested in, such as `address` or `block_id`.
> -   The match string is used to compare against the event\'s attribute
>     value, as identified by the attribute key.
> -   The filter type (simple or regular expression) determines the
>     rules for comparing the match string to the event\'s attribute
>     value.

The filter type can either be `SIMPLE` (an exact match to the specified
string) or `REGEX` (a match using a regular expression). In addition,
the filter type specifies `ANY` (match one or more) or `ALL` (must match
all). The following filter types are supported:

-   `SIMPLE_ANY`: The filter\'s \"match string\" must match at least one
    of the event\'s attribute values. For example, this filter type with
    the match string \"`abc`\" would succeed for a single event with the
    following attributes, because it matches the attribute value `abc`.

    ``` none
    Attribute(key="address",value="abc")
    Attribute(key="address",value="def")
    ```

-   `SIMPLE_ALL`: The filter\'s \"match string\" must match all of the
    event\'s attribute values. This filter type with the match string
    \"`abc`\" would fail with the previous example, because it does not
    match all the attribute values.

-   `REGEX_ANY`: The filter\'s regular expression must evaluate to a
    match for at least one of the event\'s attribute values. For
    example, this filter type with the match string \"`ab.`\" would
    succeed for a single event with the following attributes, because it
    matches the attribute value `abc`.

    ``` none
    Attribute(key="address",value="abc")
    Attribute(key="address",value="abbbc")
    Attribute(key="address",value="def")
    ```

-   `REGEX_ALL`: The filter\'s regular expression must evaluate to a
    match for all of the event\'s attribute values. This filter type
    with the match string \"`ab.`\" would fail with the previous
    example, because it doesn\'t match all three attribute values above.
    The match string `[ad][be]*[cf]` would succeed.

### Event Subscription Protobuf

Event subscriptions are submitted and serviced over a ZMQ socket using
the validator\'s messaging protocol.

An event subscription is represented with the following protobuf
messages, which are defined in `sawtooth-core/protos/events.proto`.

```python
message EventSubscription {
  string event_type = 1;
  repeated EventFilter filters = 2;
}

message EventFilter {
  string key = 1;
  string match_string = 2;

  enum FilterType {
      FILTER_TYPE_UNSET = 0;
      SIMPLE_ANY = 1;
      SIMPLE_ALL = 2;
      REGEX_ANY  = 3;
      REGEX_ALL  = 4;
    }
    FilterType filter_type = 3;
}
```

A `ClientEventsSubscribeRequest` envelope is used to submit subscription
requests and receive the responses.

```protobuf
message ClientEventsSubscribeRequest {
    repeated EventSubscription subscriptions = 1;
    // The block id (or ids, if trying to walk back a fork) the subscriber last
    // received events on. It can be set to empty if it has not yet received the
    // genesis block.
    repeated string last_known_block_ids = 2;
}
```

The validator responds with a `ClientEventsSubscribeResponse` message
that specifies whether the subscription was successful.

```protobuf
message ClientEventsSubscribeResponse {
    enum Status {
         OK = 0;
         INVALID_FILTER = 1;
         UNKNOWN_BLOCK = 2;
    }
    Status status = 1;
    // Additional information about the response status
    string response_message = 2;
}
```

When subscribing to events, an application can optionally request
\"event catch-up\" by sending a list of block IDs along with the
subscription. For more information, see [Requesting Event
Catch-Up](#requesting-event-catch-up).

## About Web Sockets and Event Subscriptions

Applications can subscribe to events by using a web socket connection to
the REST API, but there are several limitations:

-   Only Sawtooth block-commit and state-delta events are supported.
-   You cannot specify a single event type or use filters to fine-tune
    the results. A web socket subscription returns all events.
-   Event catch-up is not available.

We recommend [using ZMQ](#using-zmq-to-subscribe-to-events) for event
subscription.

For information on using web sockets, see [State Delta
WebSockets]({% link docs/1.2/rest_api/state_delta_websockets.md%}).

## Using ZMQ to Subscribe to Events

Client applications can subscribe to Hyperledger Sawtooth events using
the validator\'s [ZMQ](http://zeromq.org) messaging protocol. The
general subscription process is as follows:

1.  Construct a subscription that includes the event type and optional
    filters (zero or more).
2.  Submit the event subscription as a message to the validator.
3.  Wait for a response from the validator.
4.  Start listening for events.

This section summarizes event subscriptions, then explains the procedure
for event subscription. It also describes the following operations:

-   Correlating events to blocks
-   Requesting event catch-up
-   Unsubscribing to events


> Note
>
> This procedure uses Python examples to show how to subscribe to events.
> The process is similar for any imperative programming language that
> meets these requirements. A client application can use any language that
> provides a ZMQ library and a protobuf library. In addition, the required
> Sawtooth protobuf messages must be compiled for the chosen language.

The following steps assume that the XO transaction family has a `create`
event that is sent when a game has been created, as in this example:

```python
context.add_event(
    "xo/create", {
        'name': name,
        'creator': signer_public_key
})
```

### Step 1: Construct a Subscription


An application can use the `EventSubscription` protobuf message to
construct an event subscription. For example, in the `sawtooth`
namespace, the application could subscribe to either a `block-commit` or
`state-delta` event (or both) in the `sawtooth` namespace, using either
a `SIMPLE` or `REGEX` filter.

The following example constructs an event subscription for state-delta
events (changes in state) with a `REGEX_ANY` filter for events from the
XO transaction family.

```python
subscription = EventSubscription(
    event_type="sawtooth/state-delta",
    filters=[
        # Filter to only addresses in the "xo" namespace using a regex
        EventFilter(
            key="address",
            match_string="5b7349.*",
            filter_type=EventFilter.REGEX_ANY)
    ])
```

Note that the match string specifies the `xo` namespace as `5b7349`,
because the namespace is determined by
`hashlib.sha512('xo'.encode("utf-8")).hexdigest()[0:6]`. For more
information, see \"Addressing\" in the Go, Javascript, or Python SDK
tutorial:

-   Go: `/_autogen/sdk_TP_tutorial_go`{.interpreted-text role="doc"}
-   JavaScript: `/_autogen/sdk_TP_tutorial_js`{.interpreted-text
    role="doc"}
-   Python: `/_autogen/sdk_TP_tutorial_python`{.interpreted-text
    role="doc"}

### Step 2: Submit the Event Subscription

After constructing a subscription, submit the subscription request to
the validator. The following example connects to the validator using
ZMQ, then submits the subscription request.

```python
# Setup a connection to the validator
ctx = zmq.Context()
socket = ctx.socket(zmq.DEALER)
socket.connect(url)

# Construct the request
request = ClientEventsSubscribeRequest(
    subscriptions=[subscription]).SerializeToString()

# Construct the message wrapper
correlation_id = "123" # This must be unique for all in-process requests
msg = Message(
    correlation_id=correlation_id,
    message_type=CLIENT_EVENTS_SUBSCRIBE_REQUEST,
    content=request)

# Send the request
socket.send_multipart([msg.SerializeToString()])
```

### Step 3: Receiving the Response

After submitting the subscription request, wait for a response from the
validator. The validator will return a response indicating whether the
subscription was successful.

The following example receives the response and verifies the status.

```python
# Receive the response
resp = socket.recv_multipart()[-1]

# Parse the message wrapper
msg = Message()
msg.ParseFromString(resp)

# Validate the response type
if msg.message_type != CLIENT_EVENTS_SUBSCRIBE_RESPONSE:
    print("Unexpected message type")
    return

# Parse the response
response = ClientEventsSubscribeResponse()
response.ParseFromString(msg.content)

# Validate the response status
if response.status != ClientEventsSubscribeResponse.OK:
  print("Subscription failed: {}".format(response.response_message))
  return
```

### Step 4: Listening for Events

After the event subscription request has been sent and accepted, events
will arrive on the ZMQ socket. The application must start listening for
these events.

> Note
>
> In order to limit network traffic, individual events are wrapped in an
> event list message before being sent.

The following example listens for events and prints them indefinitely.

```python
while True:
  resp = socket.recv_multipart()[-1]

  # Parse the message wrapper
  msg = Message()
  msg.ParseFromString(resp)

  # Validate the response type
  if msg.message_type != CLIENT_EVENTS:
      print("Unexpected message type")
      return

  # Parse the response
  events = EventList()
  events.ParseFromString(msg.content)

  for event in events:
    print(event)
```

### Correlating Events to Blocks

An event originates from a specific block. That is, an event is sent to
the subscriber only when the block is committed and state is updated. As
a result, events can be treated as output from processing and committing
blocks.

An application can subscribe to both `sawtooth/block-commit` and
`sawtooth/state-delta` events to match state changes with the block in
which the changes occurred.

All lists of `block-commit` events received from the validator will
contain only a single `block-commit` event for the block that the events
came from.


> Important
>
> For forking networks, we recommend subscribing to `block-commit` events
> in order to watch for network forks and react appropriately. Without a
> subscription to `block-commit` events, there is no way to determine
> whether a fork has occurred.
>
> In addition, the best practice is to wait to react to these events until
> a number of blocks have been committed on the given fork. This provides
> some confidence that you won\'t need to revert those changes because you
> switched to a different fork.

### Requesting Event Catch-Up

An event subscription can request \"event catch-up\" information on all
historical events that have occurred since the creation of a specific
block or blocks.

The `ClientEventsSubscribeRequest` protobuf message takes a list of
block IDs (`last_known_block_ids`), which can be used to provide the
last block ID that a client has seen. If blocks have been committed
after that block, the missed events will be sent in the order they would
have occurred.


> Note
>
> Block IDs are available in `sawtooth/block-commit` events. In order to
> correlate event catch-up information, the application must subscribe to
> `sawtooth/block-commit` events, as described in the previous section.

The validator performs the following actions to bring the client up to
date:

1.  Filters the list to include only the blocks on the current chain
2.  Sorts the list by block number
3.  Sends historical events from all blocks since the most recent block,
    one block at a time

> Note
>
>
> The subscription fails if no blocks on the current chain are sent.

The following example submits a subscription request that includes event
catch-up.

```python
# Setup a connection to the validator
ctx = zmq.Context()
socket = ctx.socket(zmq.DEALER)
socket.connect(url)

# Construct the request
request = ClientEventSubscribeRequest(
    subscriptions=[subscription],
    last_known_block_ids=['000…', 'beef…'])

# Construct the message wrapper
correlation_id = "123" # This must be unique for all in-process requests
msg = Message(
    correlation_id=correlation_id,
    message_type=CLIENT_EVENTS_SUBSCRIBE_REQUEST,
    content=request)

# Send the request
socket.send_multipart([msg.SerializeToString()])
```

If a fork occurred in a missed event, one or more known block IDs may be
\"gone\". In this case, use the information in [Correlating Event to
Blocks](#correlating-events-to-blocks) to
determine the current state of the blockchain.

### Unsubscribing to Events

To unsubscribe to events, send a `ClientEventsUnsubscribeRequest` with
no arguments, wait for the response, then close the ZMQ socket.

This example submits an unsubscribe request.

```python
# Construct the request
request = ClientEventsUnsubscribeRequest()

# Construct the message wrapper
correlation_id = "123" # This must be unique for all in-process requests
msg = Message(
    correlation_id=correlation_id,
    message_type=CLIENT_EVENTS_UNSUBSCRIBE_REQUEST,
    content=request)

# Send the request
socket.send_multipart([msg.SerializeToString()])
```

The following example receives the validator\'s response to an
unsubscribe request, verifies the status, and closes the ZMQ connection.

```python
# Receive the response
resp = socket.recv_multipart()[-1]

# Parse the message wrapper
msg = Message()
msg.ParseFromString(resp)

# Validate the response type
if msg.message_type != CLIENT_EVENTS_UNSUBSCRIBE_RESPONSE:
    print("Unexpected message type")

# Parse the response
response = ClientEventsUnsubscribeResponse()
response.ParseFromString(msg.content)

# Validate the response status
if response.status != ClientEventsUnsubscribeResponse.OK:
  print("Unsubscription failed: {}".format(response.response_message))

# Close the connection to the validator
socket.close()
```


<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
