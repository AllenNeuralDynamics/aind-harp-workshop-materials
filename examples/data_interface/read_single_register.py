import harp

if __name__ == "__main__":
    file = "./data/Register_DigitalInputState.bin"
    data = harp.read(file)
    print(data)

    file = "./data/Register_AnalogData.bin"
    data = harp.read(file)
    print(data)
