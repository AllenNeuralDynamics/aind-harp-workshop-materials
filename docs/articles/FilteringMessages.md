# Filtering Harp messages

- As you probably noticed right after running the previous snippet, the device is sending a lot of messages. This is because this specific board has a high-frequency periodic event associated with ADC readings. We will come back to this point later, but for now, we will filter out these messages so we can look at other, lower-frequency messages from the device.
- To filter messages from a specific register we can use `FilterRegister(Harp.Behavior)` operator. This operator can be added in front of any stream of Harp messages in the workflow.
- Add a `SubscribeSubject` and subscribe to the `BehaviorEvents` stream.
- Add the `FilterRegister(Harp.Behavior)` operator and assign the `Register` property to the register you want to filter on (`AnalogData`).
- Modify the `FilterType` property to `Exclude` to filter out the messages from the specified register.
- Check the output of `FilterRegister`

> [!NOTE]
> Sometimes it may be easier to exclude registers using the generic API rather the device-specific one. This can be done using the `FilterRegister(Bonsai.Harp)` operator from the `Harp` package. This operator allows you to filter messages based on the register address number (e.g. `Address=44`), but it is otherwise interchangeable with the previous operator.

:::workflow
![FilteringMessages](~/workflows/FilteringMessages.bonsai)
:::
