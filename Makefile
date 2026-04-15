NAME = amn

SRCS = $(wildcard *.asm)
OBJS = $(SRCS:.asm=.o)

$(NAME): $(OBJS)
	ld $(OBJS) -o $(NAME)

%.o: %.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f $(OBJS)
	rm -f $(NAME)

.PHONY: clean
