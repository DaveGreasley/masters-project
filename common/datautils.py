import zipfile as zip
import pandas as pd

def load_ce_results(filename):
    with zip.ZipFile(filename) as results_zip:
        with results_zip.open(results_zip.namelist()[0]) as results_file:
            data = pd.read_csv(results_file)
            data.loc[:, 'Energy'] *= 1e-6 # Convert energy to Joules
            data.loc[:, 'Benchmark'] = data['Benchmark'].str.replace('.x', '')

            return data.groupby(['Benchmark','Flags', 'Type', 'RunId'], as_index=False).agg({'Energy':'mean', 'Time':'mean'})
