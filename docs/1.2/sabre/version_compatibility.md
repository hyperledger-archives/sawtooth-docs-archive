# Sabre and Sawtooth Version Compatibility

The following table shows the compatible versions of the Sabre
transaction processor, Sabre SDK, and Sawtooth Rust SDK. It also shows
the Docker tag for the Sabre transaction processor image.

> -   The Sabre transaction processor versions are the versions used as
>     part of the transaction processor's registration.
> -   The Sabre SDK versions are the Crate versions of the Rust library
>     that should be set in the Cargo.toml file.
> -   The Docker tag is the tag that should be used for the
>     hyperledger/sawtooth-sabre-tp image if including in a
>     docker-compose yaml file.
> -   The Sawtooth Rust SDK versions are the Crate versions of the Rust
>     library that should be set in the Cargo.toml file.

<table>
<thead>
<tr>
<th>Sabre Transaction Processor</th>
<th>Sabre SDK</th>
<th>Docker</th>
<th>Sawtooth Rust SDK</th>
<th>Changes</th>
</tr>
</thead>
<tbody>
<tr>
<td>0.0</td>
<td>0.1</td>
<td>0.1</td>
<td>&gt; 0.2</td>
<td>&nbsp;</td>
</tr>
<tr>
    <td>0.2</td>
    <td>0.2</td>
    <td>0.2</td>
    <td>&gt; 0.3</td>
    <td>
        <ul>
            <li>Transaction context is a trait</li>
            <li>API has new <code>get_state_entry</code> to get one entry and
                <code>get_state_entries</code> to get multiple entries
                (plus corresponding functions for set and delete)</li>
        </ul>
    </td>
</tr>
<tr>
    <td>0.3</td>
    <td>0.3</td>
    <td>0.3</td>
    <td>&gt; 0.3</td>
    <td>
        <ul>
            <li>Adds native rust implementation of the proto messages to the
                Sabre SDK and is used by the Sabre Transaction Processor.</li>
            <li>Adds no-op logging macros to the Sabre SDK</li>
        </ul>
    </td>
</tr>
<tr>
    <td>0.4</td>
    <td>0.4</td>
    <td>0.4</td>
    <td>&gt; 0.3</td>
    <td>
        <ul>
            <li>Replaces the no-op log macros with macros that will marshal the
                log back to the Sabre Transaction Processor where it will be
                logged.</li>
        </ul>
    </td>
</tr>
<tr>
    <td>0.5</td>
    <td>0.5</td>
    <td>0.5</td>
    <td>&gt; 0.3</td>
    <td>
        <ul>
            <li>Replaces all <em>ActionBuilder</em> errors with a single
                <code>ActionBuildError</code> and adds the
                <code>into_payload_builder</code> method to all
                <em>ActionBuilders</em>.</li>
        </ul>
    </td>
</tr>
</tbody>
</table>
