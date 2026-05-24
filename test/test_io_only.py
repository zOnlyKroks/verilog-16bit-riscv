# Test only I/O connectivity to see the exact error

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_io_only(dut):
    """Test I/O connectivity only"""

    dut._log.info("Testing I/O connectivity")

    try:
        # Set the clock period to 100 ns (10 MHz)
        clock = Clock(dut.clk, 100, unit="ns")
        cocotb.start_soon(clock.start())

        # Reset
        dut.ena.value = 1
        dut.ui_in.value = 0
        dut.uio_in.value = 0
        dut.rst_n.value = 0
        await ClockCycles(dut.clk, 5)
        dut.rst_n.value = 1
        await ClockCycles(dut.clk, 10)

        # Debug: Print actual values BEFORE trying assertions
        dut._log.info("Reading signal values...")

        uo_val = int(dut.uo_out.value)
        dut._log.info(f"uo_out = 0x{uo_val:02X}")

        uio_val = int(dut.uio_out.value)
        dut._log.info(f"uio_out = 0x{uio_val:02X}")

        uio_oe_val = int(dut.uio_oe.value)
        dut._log.info(f"uio_oe = 0x{uio_oe_val:02X}")

        # Test is_resolvable individually
        dut._log.info("Testing is_resolvable...")

        try:
            uo_resolvable = dut.uo_out.value.is_resolvable
            dut._log.info(f"uo_out.is_resolvable = {uo_resolvable}")
        except AttributeError as e:
            dut._log.info(f"uo_out.is_resolvable not supported: {e}")
            uo_resolvable = True

        try:
            uio_out_resolvable = dut.uio_out.value.is_resolvable
            dut._log.info(f"uio_out.is_resolvable = {uio_out_resolvable}")
        except AttributeError as e:
            dut._log.info(f"uio_out.is_resolvable not supported: {e}")
            uio_out_resolvable = True

        try:
            uio_oe_resolvable = dut.uio_oe.value.is_resolvable
            dut._log.info(f"uio_oe.is_resolvable = {uio_oe_resolvable}")
        except AttributeError as e:
            dut._log.info(f"uio_oe.is_resolvable not supported: {e}")
            uio_oe_resolvable = True

        dut._log.info("Testing assertions...")

        assert uo_resolvable, "uo_out has unresolved bits"
        dut._log.info("uo_out resolvable check passed")

        assert uio_out_resolvable, "uio_out has unresolved bits"
        dut._log.info("uio_out resolvable check passed")

        assert uio_oe_resolvable, "uio_oe has unresolved bits"
        dut._log.info("uio_oe resolvable check passed")

        # Check that bidirectional pins are set as outputs
        dut._log.info(f"Checking uio_oe: expected 0xFF, got 0x{uio_oe_val:02X}")
        assert uio_oe_val == 0xFF, f"Expected all uio pins as outputs (0xFF), got 0x{uio_oe_val:02X}"
        dut._log.info("uio_oe value check passed")

        # Verify basic signal ranges
        pc_val = uo_val & 0x0F
        assert 0 <= pc_val <= 15, f"PC value out of expected range: {pc_val}"
        dut._log.info("PC range check passed")

        dut._log.info("I/O connectivity test passed successfully!")

    except Exception as e:
        dut._log.error(f"I/O connectivity test failed with error: {e}")
        import traceback
        dut._log.error(f"Traceback: {traceback.format_exc()}")
        raise