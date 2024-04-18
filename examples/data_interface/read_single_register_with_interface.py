import harp

if __name__ == "__main__":
    device = harp.create_reader("./data/device.yml")
    print(dir(device))
    file = "./data/Register_DigitalInputState.bin"
    data = device.DigitalInputState.read(file)
    print(data)
