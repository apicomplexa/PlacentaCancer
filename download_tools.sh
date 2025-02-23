mkdir ./tools;
cd ./tools;

echo 
echo ====== DOWNLOAD SRA Toolkit ======
echo
wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar -vxzf sratoolkit.tar.gz
mkdir sratoolkit && mv sratoolkit.*/* sratoolkit
./sratoolkit.3.0.1-ubuntu64/bin/vdb-config -i

echo
echo ====== SET NCBI ApiKey ======
echo
env NCBI_API_KEY=4cf167d8d16b5558aab9dbd4d0a015e4ed09

echo
echo ====== DOWNLOAD FastQC ======
echo
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc_v0.11.9.zip
chmod +x FastQC/fastqc

echo
echo ====== DOWNLOAD MultiQC ======
echo
pip install multiqc

echo
echo ====== DOWNLOAD NextFlow ======
echo
curl -s https://get.nextflow.io | bash

echo
echo ====== DOWNLOAD Kallisto ======
echo
git clone https://github.com/pachterlab/kallisto.git
apt-get install autoconf
cd kallisto && mkdir build && cd build && cmake .. && make
