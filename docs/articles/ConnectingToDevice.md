# Connecting to the Harp device

- Add the `Device(Harp.Behavior)` operator and assign the `PortName` property.
- Add a `PublishSubject` operator and name it `BehaviorEvents`.
- Add a `BehaviorSubject` source, and name it `BehaviorCommands`. A [Source Subject](https://bonsai-rx.org/docs/articles/subjects.html#source-subjects) of a given type can be added by right-clicking an operator of that type (e.g.`Device`) and selecting `Create Source` -> `BehaviorSubject`.
- Run Bonsai and check check the output from the device.

:::workflow
![ConnectionPattern](~/workflows/ConnectionPattern.bonsai)
:::
