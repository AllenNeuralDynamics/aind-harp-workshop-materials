
# TODO
-Mention the opreg/dump when talking about logging.


# Cookbook

## 0- Install Bonsai and dependencies

- Follow these [instructions](https://harp-tech.org/articles/intro.html)

## 1- Installing the Harp Behavior device API

Each Harp device has a unique Bonsai API that is used to interact with the device. To install the Harp Behavior device Bonsai API:

- Open the Bonsai Package Manager.
- Switch the Package Source to "nuget.org".
- Search for `Harp.Behavior`.
- Install the package.

## 2- Connecting to the Harp device

- Add the `Device(Harp.Behavior)` operator and assign the `PortName` property.
- Add a `PublishSubject` operator and name it `BehaviorEvents`.
- Add a `BehaviorSubject` source, and name it `BehaviorCommands`. A [Source Subject](https://bonsai-rx.org/docs/articles/subjects.html#source-subjects) of a given type can be added by right-clicking an operator of that type (e.g.`Device`) and selecting `Create Source` -> `BehaviorSubject`.
- Run Bonsai and check check the output from the device.

## 3- Filtering messages

- As you probably noticed in 2- the device is sending a lot of messages. This is because this specific board has a high-frequency period event associated with the ADC readings. We will come back to this point later, but for now, we will filter out these messages so we can look at other, lower-frequency messages from the device.
- To filter messages from a specific register we can use `FilterRegister(Harp.Behavior)` operator. This operator can be added in front of any stream of Harp messages in the workflow.
- Add a `SubscribeSubject` and subscribe to the `BehaviorEvents` stream.
- Add the `FilterRegister(Harp.Behavior)` operator and assign the `Register` property to the register you want to filter on (`AnalogData`).
- Modify the `FilterType` property to `Exclude` to filter out the messages from the specified register.
- Check the output of `FilterRegister`

> **_NOTE:_** Sometimes it may be easier to exclude registers using the generic API rather the device-specific one. This can be done using the `FilterRegister(Bonsai.Harp)` operator from the `Harp` package. This operator allows you to filter messages based on the register address number (e.g. `Address=44`), but it is otherwise interchangeable with the previous operator.

## 4- Interacting with Core Registers

### 4.1- Reading the firmware version using the low-level API

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

### 4.2 - Reading the firmware version using the abstracted API

- The ability to manipulator "raw" Harp messages is very useful for debugging new devices. However, for most applications, we will want to use the abstracted API instead of having to know the register specification as in the previous point:
- Add a `CreateMessage(Bonsai.Harp)` operator
- Select `FirmwareVersionHigh` under `Payload`. This change will automatically populate the `Address` and `PayloadType` to match the select register. You will still need to assign a `MessageType`, in this case, `Read`.
- Re-run the previous example using this operator instead.

### 4.3- Parsing the message payload

- After the last step, you should see a message from the register `FirmwareVersionHigh`. However, we have yet to parse the message payload to see the actual firmware version.
- Mimicking the previous steps, we will start by learning how to parse the payload using the low-level API:
  - Add a `Parse(Bonsai.Harp)`. This operator will not only parse the Harp Message payload to the specified type but also filter out messages that do not match the specified parsing pattern (e.g. other registers).
  - Assign the properties as in 4.1
  - Repeat 4.2 but now check the value of the firmware version.
- Once again, we can also use the abstracted API to simplify the parsing process:
  - Add a `Parse(Bonsai.Harp)` operator
  - Select `FirmwareVersionHigh` under `Payload`
  - Re-run the previous example using this operator instead.


## 5- Parsing AnalogData events

# TODO - Circuit diagram with a photodiode or pot?


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