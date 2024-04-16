# Parsing AnalogData `Event`s

In 3, we mentioned the AnalogData as a high-frequency event that carries the ADC readings. We can easily parse the payload of this register following the logic in 4.3. However, it is important to note that, as opposed to `FirmwareVersionHigh` which belongs to the core registers common across all Harp devices, `AnalogData` is a Harp Behavior specific register. As result, we must use the `Harp.Behavior` package to parse this register:

- Subscribe to the `BehaviorEvents` stream.
- Add a `Parse(Harp.Behavior)` operator
- Set `Register` to `AnalogData`
- The output type of `Parse` will now change to a structure with the fields packed in this register.
- To select the data from channel 0, right-click on the `Parse` operator and select `AnalogInput0`.
- Run Bonsai and check the output of the `AnalogInput0` stream.

You will notice that despite the timestamp present in the message, the `AnalogInput0` output stream is not timestamped. This is because the `Parse` operator does not propagate the timestamp from the original message by default. In cases where the timestamp is necessary, for each `Payload` we have a corresponding `TimestampedPayloads` that can be selected in the `Parse` operator. This will add an extra field to the structure, `Seconds`, that contains the parsed timestamp of the original message:

- Modify the `Register` property to `TimestampedAnalogData`
- Select the `AnalogInput0` and `Seconds` members from the output structure.
- Optionally pair the elements into a `Tuple` using the `Zip` operator.

:::workflow
![ParseAnalogData](~/workflows/ParseAnalogData.bonsai)
:::
