import styles from '../styles/dataItem'

import React from 'react'
import { translate } from 'cozy-ui/react/I18n'

export const DataItem = ({ t, dataType }) => (
  <li className={styles['col-data-item']}>
    <svg className={styles['col-data-item-icon']}>
      <use xlinkHref={require('../assets/sprites/icon-' + dataType + '.svg')} />
    </svg>
    {t(`dataType.${dataType}`)}
  </li>
)

export default translate()(DataItem)
