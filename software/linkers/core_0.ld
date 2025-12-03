ENTRY(_start)

PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}

MEMORY
{
  RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 128M
  PERIPHERALS (rwx) : ORIGIN = 0x20000000, LENGTH = 0x4000
}

SECTIONS
{

  .tohost_section 0x20000000 :
  {
    . = ALIGN(8);
    tohost = .;
    QUAD(0);
  } > PERIPHERALS : data

  .fromhost_section 0x20001000 :
  {
    . = ALIGN(8);
    fromhost = .;
    QUAD(0);
  } > PERIPHERALS : data

  .putchar_stdout_section 0x20002000 (NOLOAD) :
  {
    . = ALIGN(8);
    putchar_stdout = .;
    QUAD(0);
  } > PERIPHERALS : data

  . = ORIGIN(RAM);

  .text :
  {
    _start = .;
    *(.text)
    *(.text.*)
    . = ALIGN(8);
    *(.rodata)
    *(.rodata.*)
  } > RAM : text

  .data :
  {
    *(.data)
    *(.data.*)
  } > RAM : data


  .bss :
  {
    *(.bss)
    *(.bss.*)
    *(COMMON)
  } > RAM : data

  _end = ALIGN(8);
}
