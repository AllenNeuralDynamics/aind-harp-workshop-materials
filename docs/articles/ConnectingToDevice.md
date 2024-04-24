# Connecting to the Harp device

- Add the `Device(Harp.Behavior)` operator and assign the `PortName` property.
- Add a `PublishSubject` operator and name it `BehaviorEvents`.
- Add a `BehaviorSubject` source, and name it `BehaviorCommands`. A [Source Subject](https://bonsai-rx.org/docs/articles/subjects.html#source-subjects) of a given type can be added by right-clicking an operator of that type (e.g.`Device`) and selecting `Create Source` -> `BehaviorSubject`.
- Run Bonsai and check check the output from the device.

> [!TIP]
> Any operator in Bonsai can be inspected during runtime by double-clicking on the corresponding node. This will display the output of the operator in a floating window.

:::workflow
![ConnectionPattern](~/workflows/ConnectionPattern.bonsai)
:::

> [!NOTE]
> Using the device-specific `Device` operator is the recommended way to connect to a Harp device. This operator runs an additional validation step that ensures that the device you are attempting to connect to matches the interface you are trying to use. For cases where this check is not necessary, you can use the generic `Device` operator, which is available in the `Bonsai.Harp` package.