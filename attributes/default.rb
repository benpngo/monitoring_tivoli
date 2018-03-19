default['monitoring_tivoli']['linux_base'] = 'tivoli_linux_base'
default['monitoring_tivoli']['linux_FP5'] = 'tivoli_linux_FP5'
# Temporary download folder
#default['monitoring_tivoli']['tmp_folder'] = '/tmp/'

# Default install path
default['monitoring_tivoli']['install_path'] = '/opt/IBM/ITM'
default['monitoring_tivoli']['key'] = 'IBMTivoliMonitoringEncryptionKey'
default['monitoring_tivoli']['product_code'] = nil

default['monitoring_tivoli']['monitoring_servers'] = ['prod1', 'prod2']
default['monitoring_tivoli']['pre_prod_monitor_servers'] = ['preprod1', 'preprod2']