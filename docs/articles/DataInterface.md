# Data Interface

## Collecting data

Use the last workflow from the previous section to collect data from your Harp Device. Additionally, if you have another Harp Behavior board and one Clock Synchronizer board, attempt to collect data from both devices simultaneously from two computers:

- Connect the `ClkOut` line from the Clock Synchronizer to the `ClkIn` line of the Harp Behavior board(s).
- Connect a button/switch to one of the digital input lines of the Harp Behavior board(s).
- Start the workflow and log all the data from the device to be analyzed later.

## Setting up the python environment

To analyze the data, you will need to install [harp-python package](https://harp-tech.org/articles/python.html).

```cmd
python -m venv .venv
.venv\Scripts\activate
pip install harp-python
```

## Analyzing single register data

A single register, in its rawest form, can be parsed as follows:

```python
import harp
file = "./data/Behavior_32.bin"
data = harp.read(file)
```

## Analyzing data with a device.yml file

If you have access to the `device.yml` file, you can parse the data as follows:

```python
import harp
device = harp.create_reader("./data/device.yml")
file = "./data/Behavior_32.bin"
data = device.DigitalInputState.read(file)
```

## Analyzing data using the recommend logging spec

If you follow the recommend logging spec covered at the end of last section, where the device.yml is in the same folder as all registers, you can parse the data as follows:

```python
device = harp.create_reader("./data/MyDevice.harp")
data = device.DigitalInputState.read()
```

## Verify that both behavior boards are synchronizer

- Using the `DigitalInputState` register, parse the value of of the button/switch and verify if both boards are synchronized (i.e. report the same timestamp for the same button press).