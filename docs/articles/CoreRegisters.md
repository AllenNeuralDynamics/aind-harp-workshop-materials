# Core Registers

## Reading the firmware version using the low-level API

- Each Harp device has a core register that contains the firmware version flashed on the board. An easy way to check what is the Major version of the firmware is to read from this register. [This register follows the following structure](https://harp-tech.org/protocol/Device.html#table---list-of-available-common-registers):

```yml
  FirmwareVersionHigh:
    address: 6
    type: U8
    access: Read
```

To read from this register, we need to create a `Read`-type message to this register:

- Add a `CreateMessage(Bonsai.Harp)` operator
- Select `CreateMessagePayload` under `Payload`. This will allow us to specify all the fields of the Harp message.
- Populate the properties `MessageType`, `Address` and `PayloadType` with the register information above.
- In several cases we will want to trigger the reading of the register with some other event. For debugging, one useful trick is to use `KeyDown(Windows.Input)` operator that sends a notification when a key is pressed. To prevent sporadic triggers set the `Filter` property to a specific key (e.g. `1`).
- Connect this operator to the `CreateMessage` operator.
- In 3, we used `SubjectSubject` to create a "one-to-many" pattern (i.e. one `Device` source to two parallel `FilterMessage` operators). When sending commands to a device we usually want to create a "many-to-one" pattern instead. This can be done by using the `MulticastSubject` operator with the `BehaviorCommands` as the target subject.
- Add a `MulticastSubject` operator after the `CreateMessage` operator.
- Run Bonsai and click `1` to trigger the reading of the firmware version. What do you see in the filtered device output?

:::workflow
![CreateRawMessageFirmwareHigh](~/workflows/CreateRawMessageFirmwareHigh.bonsai)
:::


## Reading the firmware version using the abstracted API

- The ability to manipulator "raw" Harp messages is very useful for debugging new devices. However, for most applications, we will want to use the abstracted API instead of having to know the register specification as in the previous point:
- Add a `CreateMessage(Bonsai.Harp)` operator
- Select `FirmwareVersionHigh` under `Payload`. This change will automatically populate the `Address` and `PayloadType` to match the select register. You will still need to assign a `MessageType`, in this case, `Read`.
- Re-run the previous example using this operator instead.


:::workflow
![CreateApiMessageFirmwareHigh](~/workflows/CreateApiMessageFirmwareHigh.bonsai)
:::

## Parsing the message payload

- After the last step, you should see a message from the register `FirmwareVersionHigh`. However, we have yet to parse the message payload to see the actual firmware version.
- Replicating the previous steps, we will start by learning how to parse the payload using the low-level API:
  - Add a `Parse(Bonsai.Harp)`. This operator will not only parse the Harp Message payload to the specified type but also filter out messages that do not match the specified parsing pattern (e.g. other registers).
  - Assign the properties using the same values from the previous example.
- Once again, we can also use the abstracted API to simplify the parsing process:
  - Add a `Parse(Bonsai.Harp)` operator
  - Select `FirmwareVersionHigh` under `Payload`
  - Re-run the previous example using this operator instead.

:::workflow
![ParseMessageFirmwareHigh](~/workflows/ParseMessageFirmwareHigh.bonsai)
:::
