from colorama import Fore, Back, Style


print(Fore.LIGHTGREEN_EX + 'some red text')
print(Fore.LIGHTBLUE_EX + 'some red text')
print(Fore.LIGHTWHITE_EX + 'some red text')
print(Fore.LIGHTCYAN_EX + 'some red text')
print(Fore.LIGHTMAGENTA_EX + 'some red text')
print(Fore.YELLOW + 'and with a green background')
print(Fore.MAGENTA + 'and in dim text')
print(Style.RESET_ALL)
print('back to normal now')


class sh_colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_color_log(log_type, message):
    print(f"{log_type}{message}{sh_colors.ENDC}")


def print_ok(message):
    print(Fore.GREEN + f"{message}",Style.RESET_ALL, flush=True)


def print_info(message):
   print(Fore.BLUE + f"{message}",Style.RESET_ALL, flush=True)


def print_warn(message):
    print(Fore.CYAN + f"{message}",Style.RESET_ALL, flush=True)


def print_error(message):
    print(Fore.MAGENTA + f"{message}",Style.RESET_ALL, flush=True)




