import harp

if __name__ == "__main__":
    file = "./data/Register_DigitalInputstate.bin"
    data = harp.read(file)
    print(data)
