import mmap


def are_rollbacks_present_in_db_sync_logs(log_file):
    with open(log_file, 'rb', 0) as file, \
        mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as s:
        initial_rollback_position = s.find(b'rolling')
        offset = s.find(b'rolling', initial_rollback_position + len('rolling'))
        if offset != -1:
            s.seek(offset)
            if s.find(b'rolling'):
                print("Yes")
                return "Yes"
        print("No")
        return "No"


def is_string_present_in_file(file_to_check, search_string):
    encoded_search_string = str.encode(search_string)
    with open(file_to_check, 'rb', 0) as file, \
        mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as s:
        if s.find(encoded_search_string) != -1:
            s.seek(s.find(encoded_search_string))
            print(s.readline().decode("utf-8"))
            return "Yes"
        return "No"


are_rollbacks_present_in_db_sync_logs('db_sync_preprod_logfile.log')
