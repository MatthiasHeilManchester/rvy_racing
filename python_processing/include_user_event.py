import series_prcessing
import sys

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('the smoke came out')
        exit(1)

    existing: bool = sys.argv[2] == 'TRUE'
    race_number = int(sys.argv[1])
    if existing:
        series_prcessing.refresh_known_events(race_number)
    else:
        series_prcessing.collect_event_data(race_number)
    series_prcessing.generate_all_races_html()
    series_prcessing.generate_league_table_html()
    print("Done")
