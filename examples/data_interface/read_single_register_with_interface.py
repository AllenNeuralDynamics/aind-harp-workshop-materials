import harp

if __name__ == "__main__":
    device = harp.create_reader("device.yml")
    file = "./data/Register_DigitalInputState.bin"
    data = device.DigitalInputState(file)
    print(data)
