import tbot
from tbot.machine import board, connector, linux

class MyBoard(connector.ConsoleConnector, board.Board):
    baudrate = 115200
    serial_port = "/dev/ttyUSB3"

    def poweron(self):
        with tbot.ctx.request(tbot.role.LocalHost) as lo:
            lo.exec0("sispmctl", "-o", "3")

    def poweroff(self):
        with tbot.ctx.request(tbot.role.LocalHost) as lo:
            lo.exec0("sispmctl", "-f", "3")

    def connect(self, mach):
        return mach.open_channel("picocom", "-b", str(self.baudrate), self.serial_port)

def register_machines(ctx):
    ctx.register(MyBoard, tbot.role.Board)
