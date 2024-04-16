
# TODO
-Mention the opreg/dump when talking about logging.


# Cookbook

## 0- Install Bonsai and dependencies

- Run `./bonsai/setup.cmd` to install Bonsai and its dependencies.
- Follow these [instructions](https://harp-tech.org/articles/intro.html)
- Documentation on most concepts covered in these exercises can be found [here](https://harp-tech.org/articles/operators.html).

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

## 6 - Parsing a DigitalInput events

While the `AnalogData` is a register that sends periodic message (~1kHz), other messages are triggered by non-period events. One example is how the digital input lines. In this board, register `DigitalInputState` emits an event when any of the digital input lines change state. It is important to note that similar to other devices (e.g. Open-Ephys acquisition boards), the state of all lines is multiplexed into a single integer (`U8`), where each bit represents that state of each line. As a result, depending on the exact transformation you want to apply to the data, you may need to use the `Bitwise` operators to extract the state of each line:

- Subscribe to the `BehaviorEvents` stream.
- Add a `Parse(Harp.Behavior)` operator
- Set `Register` to `DigitalInputStatePayload` (You can also use `TimestampedDigitalInputState` if you need the timestamp)
- The output type of `Parse` will now change and propagate the state of all lines according to the demultiplexing logic of the register:

```yml
  DigitalInputs:
    bits:
      None: 0x0
      DIPort0: 0x1
      DIPort1: 0x2
      DIPort2: 0x4
      DI3: 0x8
```

- To extract the state of a specific line, use the `BitwiseAnd` operator and `Value` to the line you want to extract (e.g. `DI3`). To convert to a `Boolean`, use the `GreaterThan` operator with `Value` set to 0.
- Because the state of `DigitalInputState` changes when ANY of the lines change, we tend to use the `DistinctUntilChanged` to only propagate the message if the state of the line of interest changes.
- Finally, to trigger a certain behavior on a specific edge, we add a `Condition` operator to only allow `True` values to pass through. The behavior can easily bit inverted by adding a `BitWiseNot` operator before, or inside, the condition operator.

> **_NOTE:_** In most situations listening to the `Event` propagated by the register is sufficient, and prefered, to keep track of the full state history of the device. Alternatively, one could also switch to a "pooling"-like strategy by using a `Timer` operator that periodically asks for a `Read` from the register.


## 7- Sending commands to the device

## 7.1 - Change the state of the digital output line

The Harp Behavior device has a set of 4 registers that can be used to change the state of the digital output lines: `OutputSet`, `OutputClear`, `OutputToggle` and `OutputState`. For the sake of the example, we will use the `OutputSet` and `OutputClear` registers. These registers are used to set or clear the state of a specific line, respectively. Similarly to the `DigitalInputState`, the value of this register also multiplexes the value of all the lines. First, we will set the state of line `DO3` to `High`:

- Add a `KeyDown(Windows.Input)` operator and set the `Filter` property to a specific key (e.g. `1`).
- Add a `CreateMessage(Harp.Behavior)` operator in after the `KeyDown` operator.
- Select `OutputSetPayload` under `Payload`. Make sure the `MessageType` is set to `Write` since we will know be asking the device to change the value of one of its registers.
- In the property `OutputSet`, select the line you want to turn on (e.g. `DO3`).
- Replicate the previous steps to clear the state of the line `DO3` by using the `OutputClearPayload` instead, and the `KeyDown` operator with a different key (e.g. `2`).
- Verify that you can turn On and Off the line `DO3` by pressing the keys `1` and `2`, respectively.

## 7.2 - Changing the pulse mode of a digital output line

In most harp devices you will find registers dedicated for configuration instead of "direct control". One example is the `OutputPulseEnable` register in the Harp Behavior board. This register is used when the user wants to pulse the line for a specific, pre-programmed, duration (e.g. opening a solenoid valve for exactly 10ms). To use this feature:

- Subscribe to the `BehaviorEvents` stream.
- Add a `Take` operator.
- Add `CreateMessage(Harp.Behavior)` operator in after the `Take` operator.
- Select `OutputPulseEnablePayload` under `Payload`. Make sure the `MessageType` is set to `Write`.
- Select the line you want to pulse (e.g. `DO3`), and add a `MulticastSubject` operator to send the message to the device.
- Add another `CreateMessage(Harp.Behavior)` operator in after the `MulticastSubject` operator.
- Select `Pulse<Pin>Payload`, and set the value to the number of milliseconds you want this line to be high for on each pulse.
- Add a `MulticastSubject` operator to send the message to the device.
- Verify you see a pulse on the line `DO3` every time you press the key `1`.

> **_NOTE:_** The `BehaviorEvents`->`Take(1)` pattern will wait for the first message from the device before sending any commands, guaranteeing that the device is ready to receive commands.


## 7.3 - Getting the timestamp of a Write message


While we know that the state of the line `DO3` is changing, we do not have access to WHEN this change is taking place. Remember that for each `Write` message issued by the computer as a command, `Write` message reply should be sent back from the device. We can thus follow a similar logic to 6.1 to get the timestamp of the reply message:

- Subscribe to the `BehaviorEvents` stream.
- Add a `Parse(Harp.Behavior)` operator and set the `Register` to `TimestampedOutputSet`.
- Expose the `Value` and `Seconds` members of the output structure.
- Add a `BitwiseAnd(DO3)` and a `GreaterThan(0)` operator, after `Value` to extract the state of the line `DO3`.
- Add a `Condition` operator to only allow `True` values to pass through (since we are only interested in changes of `DO3`).
- Recover the initial timestamp of the message by using a `WithLatestFrom` operator connecting the output of `Condition` and `Seconds`.

> **_NOTE:_** More documentation on how to manipulate timestamped messages can be found [here](https://harp-tech.org/articles/message-manipulation.html)


## 7.4 - Closing the loop with PWM

Building on top of 5, this exercise will walk you through how to achieve "close-loop" control between the duty-cycle of a closed-loop signal and the value of an ADC channel.

- Configure `DO3` to be a PWM output by setting replicating 7.2 but instead of using the `Pulse<Pin>Payload`, configure the initial frequency (e.g. 500Hz) and duty cycle (e.g. 50%) of the PWM by using `PwmFrequency<Pin>Payload` and `PwmDutyCycle<Pin>Payload`.
- Add a `KeyDown(Windows.Input)` operator and set the `Filter` property to a specific key (e.g. `Up`).
- Add a `CreateMessage(Harp.Behavior)` operator in after the `KeyDown` operator, and set it to `PwmStart` and match the value to the pin you are using (e.g. `DO3`).
- Repeat the previous steps but now set the `PwmStop` register to stop the PWM signal when the key `Down` is pressed.
- Verify that you can start and stop the PWM signal.

- Resume the pattern in 5. and publish the value of the ADC channel 0 via a `PublishSubject` named `Photodiode`.
- Add a `Slice` operator to down-sample the signal to a more manageable update frequency (e.g. 100Hz) by setting the `Step` property to `10`. This is advised since the Behavior board is only spec'ed to run commands at 1kHz. Different hardware / functionality may require different sampling rates, so be sure to run tests before deploying the system.
- Subscribe to the `Photodiode` stream and add a `Rescale` operator. According to the [documentation of the Harp Behavior board](https://harp-tech.org/api/Harp.Behavior.html#registers), the duty cycle register only accepts values between 1 and 99. As a result, we need to rescale the value of the ADC channel to match this range. Set the `Max` and `Min` properties to the maximum and minimum values of the Photodiode signal. Set `RangeMax` and `RangeMin` to 99 and 1, respectively. Finally, to ensure values are "clipped" to the range, set `RescaleType` to `Clamp`.
- Finally, add a `Format(Harp.Behavior)` operator after the `Rescale` node. `Format`, similarly to `CreateMessage` is a Harp message constructor. It differs from `CreateMessage` in that it uses the incoming sequence (in this case the rescaled value of the ADC channel) to populate the message, instead of setting it as a property.
- Add a `MulticastSubject` operator to send the message to the device.


## 8- Logging