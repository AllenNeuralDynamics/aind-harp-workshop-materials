import harp

if __name__ == "__main__":
    device = harp.create_reader("./data/MyDevice.harp")
    data = device.AnalogData.read()
    print(data)
