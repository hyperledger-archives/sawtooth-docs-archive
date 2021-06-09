---
title: Error Responses
---

When the REST API encounters a problem, or receives notification that
the validator has encountered a problem, it will notify clients with
both an appropriate HTTP status code and a more detailed JSON response.

# HTTP Status Codes

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

  ---------------------------------------------------------------------------
  Code   Title          Description
  ------ -------------- -----------------------------------------------------
  400    Bad Request    The request was malformed in some way, and will need
                        to be modified before resubmitting. The accompanying
                        JSON response will have more details.

  404    Not Found      The request was well formed, but the specified
                        identifier did not correspond to any resource in the
                        validator. Returned by endpoints which fetch a single
                        resource. Endpoints which return lists of resources
                        will simply return an empty list.

  500    Internal       Something is broken internally in the REST API or the
         Server Error   validator. This may be a bug; if it is reproducible,
                        the bug should be reported.

  503    Service        The REST API is unable to communicate with the
         Unavailable    validator. It may be down. You should try your
                        request later.
  ---------------------------------------------------------------------------

# JSON Response

In the case of an error, rather than a *data* property, the JSON
response will include a single *error* property with three values:

> -   *code* (integer) - a machine readable error code
> -   *title* (string) - a short headline for the error
> -   *message* (string) - a longer, human-readable description of what
>     went wrong

::: note
::: title
Note
:::

While the title and message may change in the future, the error code
will **not** change; it is fixed and will always refer to this
particular problem.
:::

## Example JSON Response

``` json
{
  "error": {
    "code": 30,
    "title": "Submitted Batches Invalid",
    "message": "The submitted BatchList is invalid. It was poorly formed or has an invalid signature."
  }
}
```

# Error Codes and Descriptions

  ---------------------------------------------------------------------------
  Code   Title          Description
  ------ -------------- -----------------------------------------------------
  10     Unknown        An unknown error occurred with the validator while
         Validator      processing the request. This may be a bug; if it is
         Error          reproducible, the bug should be reported.

  15     Validator Not  The validator has no genesis block, and so cannot be
         Ready          queried. Wait for genesis to be completed and
                        resubmit. If you are running the validator, ensure it
                        was set up properly.

  17     Validator      The request timed out while waiting for a response
         Timed Out      from the validator. It may not be running, or may
                        have encountered an internal error. The request may
                        not have been processed.

  18     Validator      The validator sent a disconnect signal while
         Disconnected   processing the response, and is no longer available.
                        Try your request again later.

  20     Invalid        The validator sent back a response which was not
         Validator      serialized properly and could not be decoded. There
         Response       may be a problem with the validator.

  21     Invalid        The validator sent back a resource with a header that
         Resource       could not be decoded. There may be a problem with the
         Header         validator, or the data may have been corrupted.

  27     Unable to      The validator should always return some status for
         Fetch Statuses every batch requested. An unknown error caused
                        statuses to be missing, and should be reported.

  30     Submitted      The submitted BatchList failed initial validation by
         Batches        the validator. It may have a bad signature or be
         Invalid        poorly formed.

  31     Unable to      The validator cannot currently accept more batches
         Accept Batches due to a full queue. Please submit your request
                        again.

  34     No Batches     The BatchList Protobuf submitted was empty and
         Submitted      contained no batches. All submissions to the
                        validator must include at least one batch.

  35     Protobuf Not   The REST API was unable to decode the submitted
         Decodable      Protobuf binary. It is poorly formed, and has not
                        been submitted to the validator.

  42     Wrong Content  POST requests to submit a BatchList must have a
         Type (submit   \'Content-Type\' header of
         batches)       \'application/octet-stream\'.

  43     Wrong Content  If using a POST request to fetch batch statuses, the
         Type (fetch    \'Content-Type\' header must be \'application/json\'.
         statuses)      

  46     Bad Status     The body of the POST request to fetch batch statuses
         Request        was poorly formed. It must be a JSON formatted array
                        of string-formatted batch ids, with at least one id.

  50     Head Not Found A \'head\' query parameter was used, but the block id
                        specified does not correspond to any block in the
                        validator.

  53     Invalid Count  The \'count\' query parameter must be a positive,
         Query          non-zero integer.

  54     Invalid Paging The validator rejected the paging request submitted.
         Query          One or more of the \'min\', \'max\', or \'count\'
                        query parameters were invalid or out of range.

  57     Invalid Sort   The validator rejected the sort request submitted.
         Query          Most likely one of the keys specified was not found
                        in the resources sorted.

  60     Invalid        A submitted block, batch, or transaction id was
         Resource Id    invalid. All such resources are identified by 128
                        character hex-strings.

  62     Invalid State  The state address submitted was invalid. Returned
         Address        when attempting to fetch a particular \"leaf\" from
                        the state tree. When fetching specific state data,
                        the full 70-character address must be used.

  66     Id Query       If using a GET request to fetch batch statuses, an
         Invalid or     \'id\' query parameter must be specified, with a
         Missing        comma-separated list of at least one batch id.

  70     Block Not      There is no block with the id specified in the
         Found          blockchain.

  71     Batch Not      There is no batch with the id specified in the
         Found          blockchain.

  72     Transaction    There is no transaction with the id specified in the
         Not Found      blockchain.

  75     State Not      There is no state data at the address specified.
         Found          

  80     Transaction    There is no transaction receipt for the transaction
         Receipt Not    id specified in the receipt store.
         Found          

  81     Wrong Content  Requests for transaction receipts sent as a POST must
         Type           have a \'Content-Type\' header of
                        \'application/json\'.

  82     Bad Receipts   Requests for transaction receipts sent as a POST must
         Request        have a JSON formatted body with an array of at least
                        one id string.

  83     Id Query       Requests for transaction receipts sent as a GET
         Invalid or     request must have an \'id\' query parameter with a
         Missing        comma-separated list of at least one transaction id.
  ---------------------------------------------------------------------------
